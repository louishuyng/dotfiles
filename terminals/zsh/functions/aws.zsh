declare -A ebprofile

ebprofile[dentist-backend-stg]=dentist 
ebprofile[dentist-frontend-stg]=dentist

function ebdeploy() {
  name=$1

  eb deploy $name --profile $ebprofile[$name]
}
