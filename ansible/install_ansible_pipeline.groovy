pipeline {
    parameters {
        string(name: 'LABEL', defaultValue: "ubuntu", description: 'Agent Label')
        string(name: 'REPO_URL', defaultValue: "git@github.com:Dubovsky-Andrey/public.git", description: 'Full GitHub URL')
        string(name: 'SCRIPT_PATH', defaultValue: "ansible/install_ansible.sh", description: 'Path to ansible install script') 
        string(name: 'BRANCH', defaultValue: "main", description: 'Branch name')
        string(name: 'GIT_CREDENTIALS_ID', defaultValue: "github-credentials-id", description: 'GitHub Credentials ID')

    }
    agent { label params.LABEL }
    
    stages {
        stage('Delete workdir '){
            steps{
                echo 'Delete Workspace Step'
                deleteDir()
            }
        }
        stage('Clone Repository') {
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "*/${params.BRANCH}"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                            url: "${params.REPO_URL}",
                            credentialsId: "${params.GIT_CREDENTIALS_ID}"
                        ]]
                    ])
                }
            }
        }

        stage('Install Ansible') {
            steps {
                script {
                    def scriptPath = params.SCRIPT_PATH
                    echo "Running script: ${scriptPath}"
                    sh "chmod +x ${scriptPath}"
                    sh "sudo ${scriptPath}"
                }
            }
        }
    }
}
