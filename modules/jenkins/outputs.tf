# Output the Helm release name of the Jenkins deployment
output "jenkins_release_name" {
  value = helm_release.jenkins.name
}

# Output the Kubernetes namespace where Jenkins is deployed
output "jenkins_namespace" {
  value = helm_release.jenkins.namespace
}