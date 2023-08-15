# 02 Hybrid Data integration using File Gateway

## [ 01 프로젝트 설명 ]
프로젝트 명 : File Gateway를 이용한 하이브리드 데이터 통합

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

<img width="1421" alt="스크린샷 2023-08-15 오전 2 35 14" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/5ecc00ac-57a4-4b0e-9c33-903ff5a24d8d">


***

## [ 05 핵심 기술 ]

### 1. VPC Endpoint

<img width="430" alt="스크린샷 2023-08-15 오전 1 52 16" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/aeffebe0-4c4e-4a23-b208-c9ddd894ec99">

#### VPC Endpoint : VPC와 AWS Service 사이의 통신을 비공개로 연결할 수 있도록 해주는 서비스이며, 이는 Gateway Endpoint와 Interface Endpoint로 나뉘어진다.


#### 1-1. Gateway Endpoint 
- VPC에 위치
- S3, DynamoDB를 지원
- Routa table을 통해 대상 서비스에게 도달
- Public IP를 사용하며, IAM Policy or Resource based policy를 사용하여 액세스 제한


#### 1-2. Interface Endpoint
- Subnet에 위치. 가용성을 위한다면 각 AZ의 subnet에 배치
- AWS 대부분의 서비스 지원
- Gateway Endpoint에 비해 높은 비용
- ENI(Elastic Network Interface)를 사용하기 때문에 Private IP가 할당되며, Security Group을 통해 액세스 제어

*** 

### 2. Storage Gateway

<img width="964" alt="스크린샷 2023-08-15 오전 2 51 43" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/49893c4c-26c7-41fb-a26a-3bda29c5f70f">


#### Storage Gateway : Cloud 기반 스토리지와 On premise를 연결하여 데이터 동합을 제공하는 서비스


#### 2-1. S3 File Gateway : NFS, SMB Protocol을 활용하, S3에 저장된 데이터에 파일로 엑세스 할 수 있음. 

#### 2-2. FSx File Gateway : Window File Server를 위한 서비스이며, 잦은 엑세스 빈도의 데이터를 위한 로컬 캐시 지원

#### 2-3. Volumne Gateway : 백업은 EBS Snapshot 형식으로 이루어 지며 Stored, Cache Volumne으로 나뉜다
- Stored Volume : 모든 데이터를 로컬에 저장 후 비동기적 AWS 백업
- Cache Volume : 자주 사용되는 데이터는 로컬에 존재하고 나머지 데이터는 AWS에 백업

#### 2-4. Tape Gateway : iSCSI 기반이며 Tape 기반 백업을 위한 서비스

### => 예정된 추후 작업, 잦은 엑세스 빈도 그리고 나머지 요구사항을 충족하기 위해 S3 File Gateway 선정

***

## [ 07 Endpoint 구성 ]

### 1. Gateway Endpoint for S3

<img width="979" alt="01 s3 gateway endpoint " src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/e42f10f8-db37-44a6-a54b-b2e9cef9471d">




<img width="1291" alt="01 s3 gateway endpoint routing table" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/e311bff7-8250-480c-9da3-e26b97716295">

=> Routing Table을 확인하니 Prefix list(CIDR List)를 생성한 Gateway Endpoint로 routing 하는 것을 알 수 있음



### 2. Interface Endpoint for Storage Gateway

<img width="1372" alt="02 storage interface endpoint config" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/6c451ddb-2b48-4116-a38a-daf18b071a26">

=> Gateway endpoint와 달리 subnet에 배치되며 ENI를 사용하기 때문에 고정 Private IP와 Security Group을 연동할 수 있음


<img width="1095" alt="02 storage interface endpoint sg" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/eaf507d4-6994-4620-be27-7becbc421244">

=> Storage Gateway를 사용하기 위한 포트와 VPC에서 Endpoint로 향하는 요청을 인바운드 룰에서 허용

***

## [ 08 File Gateway 구성 ]

### 1. Storage Gateway 생성

<img width="1383" alt="스크린샷 2023-08-15 오후 1 23 58" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/b6c64f27-0659-4982-85c2-e5447fbf2407">

=> VM의 Time zone과 Storage Gateway의 Time zone이 일치해야 함. ap-northeast-(Seoul)2 Region의 값 선택



<img width="1321" alt="스크린샷 2023-08-15 오후 1 24 15" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/1acb6e8e-91ea-4259-a986-1e8b00daced8">

=> VM에 설치할 플랫폼 다운로드 후, Vmware에 접속하여 이후 Cache Volume으로 사용할 150G 로컬 디스크를 할당



<img width="1321" alt="스크린샷 2023-08-15 오후 1 25 14" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/ed7b949c-1faf-43e6-9773-f05f3ed1c7cc">

=> Private Link를 이용하여 통신하길 원하므로, VPC Hosing -> 위에서 생성한 Storage Gateway용 "Interface Endpoint"를 연동



<img width="512" alt="스크린샷 2023-08-15 오후 1 26 18" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/b987ae37-7b32-443b-a5a7-6cf1af336344">

=> 위에서 할당한 150G 로컬 디스크를 Cache Storage로 추가



<img width="728" alt="스크린샷 2023-08-15 오후 1 26 38" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/1c208c61-286a-422e-936d-9b65f20695d6">

=> 약간의 대기 후 Running state 반환


### 2. File Sharing 생성

<img width="596" alt="스크린샷 2023-08-15 오후 1 39 36" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/65b17ad9-171e-4304-b040-d7776f79c07c">

=> 구체적인 설정을 위해 "구성 사용자 지정" 선택

<img width="571" alt="스크린샷 2023-08-15 오후 1 39 46" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/e4b9f4fe-5760-43ef-91a8-9ece7fbd9a42">

=> NAS 처럼 사용할 S3 bucket과 prefix를 설정

<img width="583" alt="스크린샷 2023-08-15 오후 1 45 31" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/91a7c19a-9a21-4f33-93f7-85d288ea42a2">

=> On premise 데이터에 대하여 잦은 Access를 원하므로 갹체의 Storage Class = Standard로 지정

<img width="598" alt="스크린샷 2023-08-15 오후 1 40 44" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/248b8bda-94c2-4e71-b561-bdbc3ef45a9f">

=> VPC Hosing을 통해 연결되므로 위에서 생성한 S3용 "Gateway Endpoint"를 연동 후 "생성"

<img width="1144" alt="file_sharing_command" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/d78d3a4d-8703-4cf6-90e5-db14775b93e7">

=> 생성한 File Share를 클릭 후 아래부분을 확인하면 위 처럼 Mount 명령어를 제공함. User의 OS에 맞게 명령어 실행

*** 

## [ 09 구축 결과 ]

* Mount할 directory를 하나 만들고 위의 Mount command 실행

```
mkdir ./mnt_storage_gateway
```


<img width="1225" alt="스크린샷 2023-08-15 오후 1 57 29" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/29ebc7ae-e32f-45c7-9ab1-c15aca5a4a6a">

=> Mount 성공. Mount한 서버에서 아래의 command를 통해 간단한 txt file을 생성하여 Test

```
touch "heungbot is king of school" > me.txt;
echo "test storage gateway mount" > ./mount_test.txt
```
<img width="547" alt="스크린샷 2023-08-15 오후 2 06 36" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/477e7726-38a3-4e49-b670-893477d8df40">

=> 파일 생성 확인


<img width="574" alt="스크린샷 2023-08-15 오후 2 06 52" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/ef531eed-4cd5-41dd-9003-303be8a58c06">

=> 약 1분 뒤의 딜레이 후, S3 bucket에도 잘 업로드 되었음





