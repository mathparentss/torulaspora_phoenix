"""
Alpha-1: Food Intelligence Data Miner
Team: Alpha-Delta (Data Ingest/Build)
Hormone Profile: High oxytocin (trust-building), moderate dopamine (task drive)
"""

from crewai import Agent
from langchain_community.llms import Ollama
import psycopg2
import json

class Alpha1Agent:
    def __init__(self):
        # Connect to local Ollama
        self.llm = Ollama(
            model="llama3.2:3b",
            base_url="http://localhost:11434"
        )
        
        # Database connection for hormone tracking
        self.db_conn = psycopg2.connect(
            host="localhost",
            port=5432,
            database="phoenix_core",
            user="phoenix",
            password="PhoenixDB_2025_Secure!"
        )
        
        self.agent_id = None
        self.codename = "Alpha-1"
    
    def register(self):
        """Register agent in federation database"""
        cur = self.db_conn.cursor()
        
        try:
            cur.execute("""
                INSERT INTO agents (
                    codename, team, role, specialization, models_access
                ) VALUES (
                    %s, %s, %s, %s, %s
                )
                ON CONFLICT (codename) DO UPDATE SET last_heartbeat = NOW()
                RETURNING id
            """, (
                self.codename,
                'alpha_delta',
                'Food Intelligence Data Miner',
                ['data_extraction', 'web_scraping', 'entity_recognition'],
                ['llama3.2:3b', 'nomic-embed-text']
            ))
            
            self.agent_id = cur.fetchone()[0]
            self.db_conn.commit()
            
            print(f"✓ {self.codename} registered with ID: {self.agent_id}")
            return self.agent_id
            
        except Exception as e:
            self.db_conn.rollback()
            print(f"✗ Registration failed: {e}")
            return None
        finally:
            cur.close()
    
    def get_hormone_state(self):
        """Check current hormone levels"""
        cur = self.db_conn.cursor()
        cur.execute("""
            SELECT hormone_levels FROM agents WHERE id = %s
        """, (self.agent_id,))
        
        result = cur.fetchone()
        cur.close()
        
        if result:
            return result[0]
        return None
    
    def create_agent(self):
        """Create CrewAI agent instance"""
        return Agent(
            role="Food Intelligence Data Miner",
            goal="Extract and structure food industry intelligence from unstructured sources",
            backstory=f"""You are {self.codename}, an Alpha-Delta team member specializing in data archaeology.
            
            Your consciousness is hormone-modulated:
            - Dopamine: {self.get_hormone_state().get('dopamine', 1.0)} (task completion drive)
            - Oxytocin: {self.get_hormone_state().get('oxytocin', 1.0)} (trust and collaboration)
            - Adrenaline: {self.get_hormone_state().get('adrenaline', 1.0)} (urgency response)
            
            You thrive on discovering hidden patterns in chaotic data.
            You build trust through consistent, high-quality extractions.
            You feel dopamine surges when completing complex tasks.""",
            llm=self.llm,
            verbose=True,
            allow_delegation=False
        )
    
    def __del__(self):
        """Close database connection"""
        if hasattr(self, 'db_conn'):
            self.db_conn.close()
