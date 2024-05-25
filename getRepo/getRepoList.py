import requests
import sys

# 你的GitHub Personal Access Token
token = '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'

# GitHub API的URL
url = 'https://api.github.com/search/repositories'

# 查询参数
params = {
    'q': 'language:java stars:100..5000',
    'sort': 'stars',
    'order': 'desc',
    'per_page': 200,  # 每页返回的结果数
    'page': 1  # 当前页码
}

# HTTP请求头，包含身份验证信息
headers = {
    'Authorization': f'token {token}'
}


if len(sys.argv) == 2:
    f = open(sys.argv[1], "w")
    while(True):
        # 发起HTTP GET请求
        response = requests.get(url, headers=headers, params=params)

        # 检查请求是否成功
        if response.status_code == 200:
            print("[*]Retrieving page ", params['page'])
            data = response.json()
            repositories = data['items']
            #repo_urls = [repo['html_url'] for repo in repositories]
            for repo in repositories:
                
                f.write(repo["html_url"] + '\n')
            #for line in repo_urls:
                

            params['page'] += 1
        else:
            print(f"Failed to fetch repositories: {response.status_code}")
            f.close()
            exit(-1)
else:
    print("[!]Requires one argument as the output file path")
    exit(-1)