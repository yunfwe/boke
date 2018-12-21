hexo clean && hexo g &&  bash -c   'rsync -avzz --delete -e "ssh -p 8050" public yunfwe@blog.yunfwe.cn:/data/blog/' && bash -c   'rsync -avzz --delete public root@www.yunfwe.cn:/data/wwwroot/' && hexo d && pause


