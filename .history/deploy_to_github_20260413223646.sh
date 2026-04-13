#!/usr/bin/env bash
set -e

# ====== 请修改这三项 ======
GITHUB_USER="Waverly745"
REPO_NAME="perricloud-blog"
BRANCH="main"
# =========================

echo "==> 1. 检查当前目录"
pwd
test -f "_config.yml" || { echo "未找到 _config.yml，请在 Hexo 项目根目录执行"; exit 1; }
test -f "package.json" || { echo "未找到 package.json，请确认这是 Hexo 项目"; exit 1; }

echo "==> 2. 检查 package.json 是否包含 build 脚本"
if ! grep -q '"build"' package.json; then
  echo "package.json 里没有 build 脚本，请先加入："
  echo '  "scripts": { "build": "hexo generate", "server": "hexo server" }'
  exit 1
fi

echo "==> 3. 写入 .gitignore"
cat > .gitignore <<'EOF'
node_modules/
public/
db.json
.deploy*/
.DS_Store
EOF

echo "==> 4. 本地生成测试"
npm install
npx hexo clean
npx hexo generate

echo "==> 5. 初始化 Git（若已存在则跳过）"
if [ ! -d ".git" ]; then
  git init
fi

echo "==> 6. 设置主分支"
git branch -M "${BRANCH}"

echo "==> 7. 提交代码"
git add .
if git diff --cached --quiet; then
  echo "没有新的变更可提交"
else
  git commit -m "Initial commit for PerriCloud blog"
fi

echo "==> 8. 配置远程仓库"
REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${REMOTE_URL}"
else
  git remote add origin "${REMOTE_URL}"
fi

echo "==> 9. 推送到 GitHub"
git push -u origin "${BRANCH}"

echo
echo "完成。下一步请去 Cloudflare Pages："
echo "Production branch: ${BRANCH}"
echo "Build command: npm run build"
echo "Build output directory: public"