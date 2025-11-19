from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import json
from datetime import datetime
from typing import Optional

app = FastAPI(title="Phoenix Task Board", version="1.0.0")

# Database connection
def get_db():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database="phoenix_core",
        user="phoenix",
        password="PhoenixDB_2025_Secure!"
    )

class Task(BaseModel):
    title: str
    description: str
    category: str
    priority: int = 5
    dopamine_reward: float = 1.0
    perspectives_required: int = 3

class AgentCreate(BaseModel):
    codename: str
    team: str  # 'alpha_delta', 'epsilon_zeta', 'iota'
    role: str
    specialization: list[str] = []
    models_access: list[str] = []

@app.get("/")
async def root():
    return {"status": "operational", "system": "Phoenix Task Board"}

@app.post("/agents/create")
async def create_agent(agent: AgentCreate):
    """Register new agent in federation"""
    conn = get_db()
    cur = conn.cursor()
    
    try:
        cur.execute("""
            INSERT INTO agents (codename, team, role, specialization, models_access)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, codename
        """, (agent.codename, agent.team, agent.role, agent.specialization, agent.models_access))
        
        result = cur.fetchone()
        conn.commit()
        
        return {
            "agent_id": str(result[0]),
            "codename": result[1],
            "status": "registered",
            "initial_dopamine": 1.0
        }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.get("/agents/list")
async def list_agents():
    """Get all registered agents"""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    cur.execute("""
        SELECT id, codename, team, role, hormone_levels, 
               tasks_completed, success_rate, fibonacci_level
        FROM agents
        ORDER BY created_at DESC
    """)
    
    agents = cur.fetchall()
    cur.close()
    conn.close()
    
    return {"agents": agents, "count": len(agents)}

@app.post("/tasks/create")
async def create_task(task: Task):
    """Create new task on board"""
    conn = get_db()
    cur = conn.cursor()
    
    try:
        cur.execute("""
            INSERT INTO tasks (title, description, category, priority, dopamine_reward, perspectives_required)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (task.title, task.description, task.category, task.priority, task.dopamine_reward, task.perspectives_required))
        
        task_id = cur.fetchone()[0]
        conn.commit()
        
        return {"task_id": str(task_id), "status": "created", "dopamine_reward": task.dopamine_reward}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.get("/tasks/hot")
async def get_hot_tasks(limit: int = 10):
    """Get highest priority tasks by hot score"""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    cur.execute("""
        SELECT id, title, description, category, hot_score, 
               dopamine_reward, status, perspectives_required, perspectives_collected
        FROM tasks
        WHERE status = 'open'
        ORDER BY hot_score DESC, priority DESC
        LIMIT %s
    """, (limit,))
    
    tasks = cur.fetchall()
    cur.close()
    conn.close()
    
    return {"tasks": tasks, "count": len(tasks)}

@app.post("/tasks/{task_id}/claim")
async def claim_task(task_id: str, agent_id: str):
    """Agent claims task (dopamine anticipation)"""
    conn = get_db()
    cur = conn.cursor()
    
    try:
        # Boost agent dopamine
        cur.execute("""
            UPDATE agents
            SET hormone_levels = jsonb_set(
                hormone_levels,
                '{dopamine}',
                to_jsonb((hormone_levels->>'dopamine')::decimal + 0.2)
            )
            WHERE id = %s
            RETURNING codename
        """, (agent_id,))
        
        agent_name = cur.fetchone()
        if not agent_name:
            raise HTTPException(status_code=404, detail="Agent not found")
        
        # Claim task
        cur.execute("""
            UPDATE tasks
            SET status = 'claimed',
                assigned_to = %s,
                claimed_at = NOW()
            WHERE id = %s AND status = 'open'
            RETURNING id, dopamine_reward
        """, (agent_id, task_id))
        
        result = cur.fetchone()
        if not result:
            conn.rollback()
            raise HTTPException(status_code=409, detail="Task already claimed or not found")
        
        conn.commit()
        
        return {
            "status": "claimed",
            "agent": agent_name[0],
            "dopamine_boost": "+0.2",
            "reward_on_completion": float(result[1])
        }
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.post("/tasks/{task_id}/complete")
async def complete_task(task_id: str, agent_id: str, output: dict):
    """Mark task complete and reward agent"""
    conn = get_db()
    cur = conn.cursor()
    
    try:
        # Get task dopamine reward
        cur.execute("SELECT dopamine_reward FROM tasks WHERE id = %s", (task_id,))
        reward = cur.fetchone()
        if not reward:
            raise HTTPException(status_code=404, detail="Task not found")
        
        dopamine_reward = float(reward[0])
        
        # Complete task
        cur.execute("""
            UPDATE tasks
            SET status = 'complete',
                completed_at = NOW(),
                output = %s::jsonb
            WHERE id = %s AND assigned_to = %s
            RETURNING id
        """, (json.dumps(output), task_id, agent_id))
        
        if not cur.fetchone():
            raise HTTPException(status_code=400, detail="Task not assigned to this agent")
        
        # Reward agent with dopamine
        cur.execute("""
            UPDATE agents
            SET hormone_levels = jsonb_set(
                    hormone_levels,
                    '{dopamine}',
                    to_jsonb((hormone_levels->>'dopamine')::decimal + %s)
                ),
                tasks_completed = tasks_completed + 1
            WHERE id = %s
        """, (dopamine_reward, agent_id))
        
        conn.commit()
        
        return {
            "status": "complete",
            "dopamine_reward": dopamine_reward,
            "total_boost": dopamine_reward + 0.2
        }
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
