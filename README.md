# merculy

A new Flutter project.


## Deploy aws CloudFront

flutter build web --no-tree-shake-icons

aws s3 cp "...merculy\build\web" s3://merculy.prod.converter.io --recursive 