#!/usr/bin/env python3
"""
End-to-end test: Agent registration → Task claim → Execution → Completion
"""

import sys
sys.path.insert(0, '/mnt/c/dev/phoenix')

from crewai import Crew
from agents.alpha_1_data_miner import Alpha1Agent
from tasks.data_extraction import create_extraction_task
import psycopg2
import json
import requests

# Database connection
def get_db():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database="phoenix_core",
        user="phoenix",
        password="${POSTGRES_PASSWORD}!"
    )

def create_test_task():
    """Create a test task in the board"""
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("""
        INSERT INTO tasks (
            title, description, category, priority, dopamine_reward, perspectives_required
        ) VALUES (
            %s, %s, %s, %s, %s, %s
        )
        RETURNING id
    """, (
        "Extract food supplier intelligence",
        """Raw data from food industry publication:
        
        'Organic Ingredients Co. (contact: supply@organicingco.com) announced new line of certified organic maple syrup from Quebec. Price: $45/gallon wholesale. Also launching gluten-free oat flour, certified by GFCO. Contact Sarah Johnson for samples.'
        """,
        "data_mining",
        8,  # High priority
        2.5,  # High dopamine reward
        1  # Only need 1 perspective for test
    ))
    
    task_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    
    print(f"✓ Test task created: {task_id}")
    return str(task_id)

def main():
    print("╔════════════════════════════════════════════════╗")
    print("║   ALPHA-1 END-TO-END FLOW TEST                ║")
    print("╚════════════════════════════════════════════════╝\n")
    
    # Step 1: Register agent
    print("STEP 1: Agent Registration")
    print("-" * 50)
    alpha1 = Alpha1Agent()
    agent_id = alpha1.register()
    
    if not agent_id:
        print("✗ Agent registration failed!")
        return
    
    print(f"Initial hormone state: {json.dumps(alpha1.get_hormone_state(), indent=2)}\n")
    
    # Step 2: Create test task
    print("STEP 2: Task Creation")
    print("-" * 50)
    task_id = create_test_task()
    print()
    
    # Step 3: Claim task (dopamine anticipation)
    print("STEP 3: Task Claiming (Dopamine Boost)")
    print("-" * 50)
    conn = get_db()
    cur = conn.cursor()
    
    # Claim task and boost dopamine
    cur.execute("""
        UPDATE agents
        SET hormone_levels = jsonb_set(
            hormone_levels,
            '{dopamine}',
            to_jsonb((hormone_levels->>'dopamine')::decimal + 0.2)
        )
        WHERE id = %s
    """, (agent_id,))
    
    cur.execute("""
        UPDATE tasks
        SET status = 'claimed',
            assigned_to = %s,
            claimed_at = NOW()
        WHERE id = %s
    """, (agent_id, task_id))
    
    conn.commit()
    print(f"✓ Task claimed by {alpha1.codename}")
    print(f"Dopamine after claim: {alpha1.get_hormone_state()['dopamine']}\n")
    
    # Step 4: Execute task with CrewAI
    print("STEP 4: Task Execution (CrewAI)")
    print("-" * 50)
    
    # Get task description
    cur.execute("SELECT description FROM tasks WHERE id = %s", (task_id,))
    raw_data = cur.fetchone()[0]
    
    # Create agent and task
    agent = alpha1.create_agent()
    task = create_extraction_task(agent, raw_data)
    
    # Execute with crew
    crew = Crew(
        agents=[agent],
        tasks=[task],
        verbose=True
    )
    
    print("Executing task with local Ollama...\n")
    result = crew.kickoff()
    
    print(f"\n✓ Task execution complete")
    print(f"Result preview: {str(result)[:200]}...\n")
    
    # Step 5: Complete task and reward
    print("STEP 5: Task Completion (Dopamine Reward)")
    print("-" * 50)
    
    cur.execute("""
        UPDATE tasks
        SET status = 'complete',
            completed_at = NOW(),
            output = %s::jsonb
        WHERE id = %s
    """, (json.dumps({"result": str(result)}), task_id))
    
    cur.execute("""
        UPDATE agents
        SET hormone_levels = jsonb_set(
                hormone_levels,
                '{dopamine}',
                to_jsonb((hormone_levels->>'dopamine')::decimal + 2.5)
            ),
            tasks_completed = tasks_completed + 1,
            success_rate = 1.0
        WHERE id = %s
    """, (agent_id,))
    
    conn.commit()
    
    final_hormones = alpha1.get_hormone_state()
    print(f"✓ Task completed and rewarded")
    print(f"Final dopamine: {final_hormones['dopamine']}")
    print(f"Total dopamine gain: +{float(final_hormones['dopamine']) - 1.0:.1f}\n")
    
    cur.close()
    conn.close()
    
    print("╔════════════════════════════════════════════════╗")
    print("║   TEST COMPLETE: ALPHA-1 OPERATIONAL          ║")
    print("╚════════════════════════════════════════════════╝")

if __name__ == "__main__":
    main()
