import functions_framework
import subprocess
import os
import json
from datetime import datetime

@functions_framework.http
def run_dbt(request):
    """
    dbt runを実行するCloud Function
    """
    try:
        # 実行開始時刻
        start_time = datetime.now()
        
        # dbtプロジェクトディレクトリを指定
        dbt_project_dir = '/workspace/dbt_project'
        profiles_dir = '/workspace/profiles'
       
        print(f"Starting dbt run at {start_time}")
        
        # dbt run実行
        result = subprocess.run(
            ['dbt', 'run', '--profiles-dir', profiles_dir],
            capture_output=True,
            text=True,
            cwd=dbt_project_dir
        )
        
        # 実行時間計算
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        
        # 結果を構造化
        response = {
            "status": "success" if result.returncode == 0 else "failed",
            "returncode": result.returncode,
            "duration_seconds": duration,
            "timestamp": end_time.isoformat(),
            "stdout": result.stdout,
            "stderr": result.stderr
        }
        
        # ログ出力
        print(f"dbt run completed with return code: {result.returncode}")
        print(f"Duration: {duration} seconds")
        
        if result.returncode == 0:
            return json.dumps(response, ensure_ascii=False), 200, {'Content-Type': 'application/json; charset=utf-8'}
        else:
            print(f"Error: {result.stderr}")
            return json.dumps(response, ensure_ascii=False), 500, {'Content-Type': 'application/json; charset=utf-8'}
            
    except Exception as e:
        error_response = {
            "status": "error",
            "message": str(e),
            "timestamp": datetime.now().isoformat()
        }
        print(f"Exception occurred: {str(e)}")
        return json.dumps(error_response, ensure_ascii=False), 500, {'Content-Type': 'application/json; charset=utf-8'}