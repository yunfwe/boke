hexo clean && hexo g && gulp &&  bash -c   'rsync -avzz --delete -e "ssh -p 8050" public yunfwe@blog.yunfwe.cn:/data/blog/' && hexo d && pause


