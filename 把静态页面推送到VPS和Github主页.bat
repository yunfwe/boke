hexo clean && hexo g && gulp && hexo d && rsync -avzz --delete public/* root@yunfwe.cn:/data/wwwroot/blog  &&  rsync -avzz --delete -e "ssh -p 8050" public yunfwe@hinote.ga:/data/blog/ 


pause