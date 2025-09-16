# merculy

A new Flutter project.


## Deploy aws CloudFront

flutter build web --no-tree-shake-icons

aws s3 cp "C:\Users\dupont\Desktop\merculy tcc\merculy\build\web" s3://merculy.prod.converter.io --recursive 

https://us-east-1.console.aws.amazon.com/cloudfront/v4/home?region=us-east-1#/distributions/E1ZJQ28BCB5ANN/invalidations