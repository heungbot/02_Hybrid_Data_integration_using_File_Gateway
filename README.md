# 02 Hybrid Data integration using File Gateway

## [ 01 프로젝트 설명 ]
프로젝트 명 : File Gateway를 이용한 하이브리드 데이터 동합

프로젝트 인원 : 1명

프로젝트 기간 : 2023.07 ~ 2023.07

프로젝트 소개 : 본 프로젝트의 주요 목표는 기업 내부의 다양한 온프레미스 데이터를 효율적으로 Amazon S3 버킷으로 이전하고, File Gateway 호스트를 다른 서버에 마운트하여 온프레미스 데이터를 원활하게 활용하는 것입니다. 이를 위해 회사 내의 특정 온프레미스 서버 시나리오를 가정하고 요구 사항을 충족하는 적합한 아키텍처를 구현하는 프로젝트 입니다.

***

## [ 02 클라이언트 상황 ]

* 과거 판매 매출액, 품목과 같은 사내 데이터들 온프레미스 서버에 저장해 두었음

* 새로운 이벤트를 성공적으로 런칭하기 위해 온프레미스 데이터들을 이용해야 함

* 온프레미스 서버 내에서 일정 주기로 특정 Directory에 백업하고 있음

* 추후 Data Lake 구축을 하고자 함

* 전략과 목표의 구체화를 위해 전사 데이터의 대규모 머신러닝 학습이 예정되어 있음

***

## [ 03 요구사항 ]

* DR 구성을 위해 Cloud로 데이터 Migration 요망

* 추후 작업을 위한 다양한 서비스 활용을 위해 공급자는 AWS로 선정

* 잦은 데이터 엑세스가 예상되므로 높은 접근성 확보

* 네트워크 보안 확보

***

## [ 04 다이어 그램 ]

<img width="1422" alt="스크린샷 2023-08-15 오전 1 44 29" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/dfdaf61f-fb62-42c8-af3e-64efe0929b61">

***

## [ 05 핵심 기술 ]

### VPC Endpoint

<img width="430" alt="스크린샷 2023-08-15 오전 1 52 16" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/aeffebe0-4c4e-4a23-b208-c9ddd894ec99">

- VPC Endpoint : VPC와 AWS Service 사이의 통신을 비공개로 연결할 수 있도록 해주는 서비스이며, 이는 Gateway Endpoint와 Interface Endpoint로 나뉘어진다.

  
### 1. Gateway Endpoint 
- VPC에 위치
- S3, DynamoDB를 지원
- Routa table을 통해 대상 서비스에게 도달
- Public IP를 사용하며, IAM Policy or Resource based policy를 사용하여 액세스 제한


### 2. Interface Endpoint
- Subnet에 위치. 가용성을 위한다면 각 AZ의 subnet에 배치
- AWS 대부분의 서비스 지원
- Gateway Endpoint에 비해 높은 비용
- ENI(Elastic Network Interface)를 사용하기 때문에 Private IP가 할당되며, Security Group을 통해 액세스 제어



### Storage Gateway

***

## [ 07 Endpoint 구성 ]

***

## [ 08 File Gateway 구성 ]

## [ 09 구축 결과 ]