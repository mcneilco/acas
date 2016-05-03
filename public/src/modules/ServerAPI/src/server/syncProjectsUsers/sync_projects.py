import json
import pprint
import psycopg2
import threading
import ConfigParser

class SyncProjectsController:
    def __init__(self, config_json, projects_json):
    	self.lock = threading.Lock()
    	self.config = json.loads(config_json)
        db_name = self.config['livedesign_db']['dbname']
        db_user = self.config['livedesign_db']['user']
        db_password = self.config['livedesign_db']['password']
        db_host = self.config['livedesign_db']['host']
        db_port = self.config['livedesign_db']['port']
        self.livedesign_conn_str = "dbname=%s user=%s password=%s host=%s port=%s "%\
                               (db_name, db_user,db_password, db_host,db_port)
        self.livedesign_db_conn = psycopg2.connect("dbname='%s' user='%s' \
                                                password='%s' host='%s' port=%s "%\
                                                (db_name, db_user,
                                                db_password, db_host,db_port))
        self.projects = json.loads(projects_json)

    def check_projects_exist(self):
	print "Checking for projects:"	
	check_project_exists_sql = "SELECT * FROM syn_project WHERE project_name = %s;"
	self.new_projects=[]
	for project in self.projects['projects']:
		self.lock.acquire()
        	cur=self.livedesign_db_conn.cursor()
        	#cur.execute("set bytea_output = 'hex'")
        	cur.execute(check_project_exists_sql,(project['name'],))
        	project_check_results=cur.fetchall()
        	self.lock.release()
        	if len(project_check_results)>0:
			print "Project "+project['name']+" exists."
		else:
			print "Project "+project['name']+" does not exist."
			self.new_projects.append(project)
	return
	
    def add_new_projects(self):
	if len(self.new_projects) > 0:
		print "Adding projects:" 	
		add_project_sql = "INSERT INTO syn_project (project_id, active, alternate_id, is_restricted, project_desc, project_name) VALUES(%s, %s, %s, %s, %s, %s) returning *;"
	for project in self.new_projects:
		self.lock.acquire()
        	cur=self.livedesign_db_conn.cursor()
        	#cur.execute("set bytea_output = 'hex'")
        	cur.execute(add_project_sql,(project['id'],project['active'],project['name'],project['is_restricted'],project['project_desc'],project['name']))
        	add_project_results=cur.fetchall()
        	self.livedesign_db_conn.commit()
        	self.lock.release()
        	cur.close()
        	print add_project_results
	return 

if __name__ == '__main__':
    import sys
    sync_projects_controller = SyncProjectsController(sys.argv[1], sys.argv[2])
    sync_projects_controller.check_projects_exist()
    sync_projects_controller.add_new_projects()
    print "successfully updated projects"

#reset_projects_sequence_sql = "psql -h 127.0.0.1 -p 3247 -U postgres -d synaptic -c \"select setval('syn_project_id_seq', (select max(project_id)+1 from syn_project));\""
#psql -h 127.0.0.1 -p 3247 -U postgres -d synaptic -c "INSERT INTO syn_project (active, alternate_id, is_restricted, project_desc, project_name) VALUES ('Y', 'Project Alias', 0, 'Description (optional)','Project name') returning *"
