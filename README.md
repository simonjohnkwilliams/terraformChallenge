# terraformChallenge

The challange was set to do the following; 

Within AWS, using Terraform and any other tools you consider appropriate:
 
Create a new VPC
Within this VPC create at least 2 application servers
Create a load balancer to farm the application.
Expose the go application to the Internet.

This should be part of a pipeline install after Terraform has the infrastructure up and running. 

On each application server install the sample go application (see below)



Goal

Sending a HTTP request to the load balancer should return the response

Hi there, I'm served from <application node hostname>!


Considerations

Share your work on a public git repo
Include a README.md with clear and concise instructions
Invocation should be a one line command string
Ensure the solution is secure.
Take care not to over engineer the solution

Bonus points
Enable the invocation and teardown of multiple environments (eg. dev, UAT, Prod)
Use Terraform modules and other best practices
Use auto scaling and multiple AZs
provide monitoring
For changes to the sample code, automate the build and delivery to the environment.
 

Sample application code (Go)
 
package main
import (
"fmt"
"net/http"
"os"
)
func handler(w http.ResponseWriter, r *http.Request) {
h, _ := os.Hostname()
fmt.Fprintf(w, "Hi there, I'm served from %s!", h)
}
func main() {
http.HandleFunc("/", handler)
http.ListenAndServe(":8484", nil)
}

Therefore this repo is about solving that challenge and learning
