#!/bin/bash

# 文件包含仓库列表
REPO_FILE="repos.txt"

# 临时目录
TEMP_DIR="temp_sync_dir"

# 检查仓库列表文件是否存在
if [ ! -f "$REPO_FILE" ]; then
  echo "$REPO_FILE does not exist. Please create it and list the repositories to sync."
  exit 1
fi

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 定义同步函数
sync_repo() {
  local gitee_repo=$1
  local github_repo=$2
  local temp_dir=$3
  local repo_name=$(basename "$gitee_repo" .git)
  
  cd "$temp_dir" || exit
  
  echo "Cloning $gitee_repo..."
  git clone --mirror "$gitee_repo"
  
  cd "$repo_name.git" || exit
  
  echo "Adding GitHub remote $github_repo..."
  git remote add github "$github_repo"
  
  echo "Pushing to GitHub..."
  git push --mirror --force github
  
  cd ..
  rm -rf "$repo_name.git"
  
  echo "Finished syncing $repo_name"
}

# 读取仓库列表并同步
while IFS=' ' read -r gitee_repo github_repo; do
  sync_repo "$gitee_repo" "$github_repo" "$TEMP_DIR"
done < "$REPO_FILE"

# 删除临时目录
rm -rf "$TEMP_DIR"

echo "All repositories have been synced."
