hexo clean && hexo g && gulp &&   rsync -avzz --delete -e "ssh -p 8050" public yunfwe@hinote.ga:/data/blog/ && hexo d && pause


