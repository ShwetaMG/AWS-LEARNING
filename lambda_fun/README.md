AWS CLOUD STORAGE COST OPTIMIZATION USING LAMBDA FUNCTION.

This is simple lambda function written in python using boto3 library to identify the stale EBS snapshots.

working : Lambda function fetches all the snapshotas from volumes which are associated with EC2 (Running and stopped). and checks the each snapshots with volumes if the volume does not exist with active instance then its consider snap shot as stale and deletes them.

TO EXECUTE THIS CODE.
- Create the lambda function 
- paste the code 
- attach the following persmission policies to function 
* under EC2 instance - 1.describesnapshots 
                        2.deletesnapshots
                        3.describevolume
                        4.describeinstances
- deploy and test.

NOTE: To understand concept and execution clearly go through the aws zero-to-hero playlist day-18 tutorial from AbhishekVeermalla youtube channel. 