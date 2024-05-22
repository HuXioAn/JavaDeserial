import requests
import sys
import re

def get_codeql_database(owner: str, repo: str, language: str, token: str):

    url = f"https://api.github.com/repos/{owner}/{repo}/code-scanning/codeql/databases/{language}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json"
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        return {
            "databaseUrl": data["url"],
            "owner": owner,
            "name": repo,
            "databaseId": data["id"],
            "databaseCreatedAt": data["created_at"],
            "commitOid": data["commit_oid"] if "commit_oid" in data else None,
            
        }
    else:
        print(f"Failed to fetch database: {response.status_code} - {response.json().get('message')}")
        return None
    
def download_codeql_database(owner: str, repo: str, language: str, token: str, output_file: str):

    url = f"https://api.github.com/repos/{owner}/{repo}/code-scanning/codeql/databases/{language}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/zip"
    }

    response = requests.get(url, headers=headers, allow_redirects=False)

    if response.status_code == 302:
        redirect_url = response.headers["Location"]
        zip_response = requests.get(redirect_url, headers=headers)

        if zip_response.status_code == 200:
            with open(output_file, "wb") as file:
                file.write(zip_response.content)
            print(f"CodeQL database downloaded successfully: {output_file}")
        else:
            print(f"Failed to download the database: {zip_response.status_code} - {zip_response.text}")
    else:
        print(f"Failed to fetch database: {response.status_code} - {response.json().get('message')}")



if __name__ == "__main__":
    token = "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"
    owner = "line"
    repo = "line-fido2-server"
    language = "java"  
    
    if len(sys.argv) != 5:
        print("[!] 4 arguments required: pathDerictory repoListFile indexLow indexHigh")
        exit(-1)
    
    outputPath = sys.argv[1]
    
    with open(sys.argv[2], 'r') as f:
        lines = f.readlines()
        i = int(sys.argv[3])
        while i < int(sys.argv[4]):
            
            line = lines[i]
            match = re.match(r"https://github.com/([^/]+)/([^/]+)", line)
            if match:
                owner, repo = match.groups()
                owner = owner.strip()
                repo = repo.strip()
            else:
                print("[!]Can not get the owner/name pair")
                exit(-1)
            
            print("[*] Querying for ", owner, "/", repo)
            result = get_codeql_database(owner, repo, language, token)
            if result:
                path = sys.argv[1]+owner+'_'+repo+'_'+str(i)+'.zip'
                print("[*] Downloading ", path)
                download_codeql_database(owner, repo, language, token, path)
        
            i += 1
