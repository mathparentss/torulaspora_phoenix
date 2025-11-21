from crewai import Agent
import psycopg2
import os

# Set Ollama environment
os.environ['OPENAI_API_KEY'] = 'sk-fake-key-for-local-ollama'
os.environ['OPENAI_BASE_URL'] = 'http://localhost:11434/v1'

class Alpha1Agent:
    def __init__(self):
        self.db_conn = psycopg2.connect(
            host="localhost", port=5432, database="phoenix_core",
            user="phoenix", password=os.getenv('POSTGRES_PASSWORD')
        )
        self.agent_id = None
        self.codename = "Alpha-1"
    
    def register(self):
        cur = self.db_conn.cursor()
        cur.execute("""
            INSERT INTO agents (codename, team, role, specialization, models_access)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (codename) DO UPDATE SET last_heartbeat = NOW()
            RETURNING id
        """, (self.codename, 'alpha_delta', 'Food Intelligence Data Miner',
              ['data_extraction'], ['llama3.2:3b']))
        self.agent_id = cur.fetchone()[0]
        self.db_conn.commit()
        print(f"✓ {self.codename} registered: {self.agent_id}")
        cur.close()
        return self.agent_id
    
    def get_hormone_state(self):
        cur = self.db_conn.cursor()
        cur.execute("SELECT hormone_levels FROM agents WHERE id = %s", (self.agent_id,))
        result = cur.fetchone()
        cur.close()
        return result[0] if result else {}
    
    def create_agent(self):
        return Agent(
            role="Food Intelligence Data Miner",
            goal="Extract structured food industry intelligence",
            backstory=f"{self.codename}: Extracts intelligence from chaos",
            llm="llama3.2:3b",  # String-based, routes via OPENAI_BASE_URL
            verbose=True
        )
    
    def __del__(self):
        if hasattr(self, 'db_conn'):
            self.db_conn.close()
