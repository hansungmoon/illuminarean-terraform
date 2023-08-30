### **인프라 담당자로서 AWS에서 VPC, EC2 인스턴스를 생성하는 담당업무를 받게 되었다.
“Terraform”을 이용하여 생성하고자 하는데 생성해야 하는 목록은 다음과 같다. (제시된 내용에는 없지만, 생성에 필요한 내용이 있다면 그 부분은 지원자님의 임의로 지정하셔도 무방하다.)
다음 목록을 작성하는데 필요한 terraform code를 작성하여 제출해주세요. (Zip 파일)**

```bash
VPC 생성 (ap-northeast-2, 172.5.0.0/16)

Subnet는 az별로 생성

EC2 생성 (az별로 3개를 생성)
a. ubuntu 22.04
b. t3.micro
```

![image](https://github.com/hansungmoon/illuminarean-terraform/assets/98951034/5fba3067-1128-4898-82d3-08c40e6007c4)



오토스케일링 그룹을 설정하여 각 AZ별로 3개의 EC2를 생성하였습니다.

EC2를 private subnet에 배포함으로써 보안을 강화하였습니다.

EC2는 지속적인 관리가 필요하기 때문에 외부 인터넷과 통신이 필요하여 NAT Gateway를 이용하여 인터넷 게이트웨이에 접근 가능하게 하였습니다.

Application Load Balancer를 public subnet에 배포하여 private subnet에 있는 EC2에서 요청 응답이 가능하도록 하였습니다.

Terraform을 사용하여 인프라 구성을 하였습니다.

DRY 원칙을 고려하여 코드의 로직을 재사용 가능한 단위로 나누어서 구성하였습니다.

원하는 위치에서 해당 코드를 호출 하여 사용할 수 있기 위해 [output.tf](http://output.tf)파일에 외부 폴더에서 필요한 값들을 내보내고 호출하는 폴더에서는 .tfstate파일에서 해당 값을 받아서 사용 할 수 있습니다.

숨겨야 되는 값들은 .auto.tfvars를 이용하여 노출되지 않도록 관리하였습니다.

```bash
/terraform/dev
├── back
│   ├── backend.tf
│   ├── main.tf
│   ├── provider.tf
│   └── variable.tf
├── instance
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
├── vpc
    ├── backend.tf
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    └── variable.tf

```

Terraform GitOps를 구성할 수 있도록 GitHub Actions로 .tfstate파일을 편하게 읽고 사용할 수 있도록 Terraform backend 기능을 이용하여 **S3에 .tfstate파일을 저장**하여 사용했습니다.

이로 인해 GitOps를 여러번 실행해도 해당 상태를 인지하고 관리할 수 있었으며, 로컬에서도 현재 상태를 읽어와서 사용할 수 있었습니다.

또한, dynamoDB를 상태잠금으로 구성하여 주어진 시간에 하나의 실행만 상태파일을 수정할 수있게 lock을 걸어서 **동시성 에러를 방지**할 수 있습니다.
