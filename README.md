# 02 Hybrid Data integration by using File Gateway

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

* Data Lake 구축을 의논하고 있음

* 전략과 목표의 구체화를 위해 전사 데이터의 대규모 머신러닝 학습이 예정되어 있음

***

## [ 03 요구사항 ]

* DR 구성을 위해 Cloud로 데이터 Migration 요망

* 추후 작업을 위한 다양한 서비스 활용을 위해 공급자는 AWS로 선정

* 잦은 데이터 엑세스가 예상되므로 높은 접근성 확보

* 네트워크 보안 확보

***

## [ 04 다이어 그램 ]

<img width="1272" alt="스크린샷 2023-08-14 오후 7 36 55" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/290835fc-4edf-4e21-ad0a-6ff208ff28ec">

***

## [ 05 구축 상황 ]
* 실제 On premise 서버가 존재하지 않으므로, 가상의 IDC를 AWS Cloud 내에서 다른 Region(ap-northeast-1)으로 구축

* 실제 구현 다이어 그램
  
<img width="1361" alt="스크린샷 2023-08-14 오후 7 35 41" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/628b0d69-e055-48de-b68c-f88d343a5247">

***

## [ 06 핵심 기술 ]


### 06-1 Site To Site VPN 

<img width="627" alt="스크린샷 2023-08-14 오후 7 15 23" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/bc46560d-1a81-4ef7-9576-cac9e79748f4">

- 두 개의 network domain이 가상의 사설 네트워크 연결을 사용하여 private 통신을 가능케 하는 AWS Managed Service.
- IPSec 기반으로 데이터 암호화
- VPC에 부착할 Virtual Private Gateway 또는 Transit Gateway와 On Premise에 연결할 Customer Gateway 사이에 두개의 VPN 터널을 생성함
- 10초 동안 트래픽이 오가지 않을 경우 터널은 down됨.
- BGP Routing Protocol을 사용하여 Network 경로를 자동으로 탐색할 수 있는 Dynamic Routing과 관리자가 직접 Network 경로를 설정하는 Static Routing이 존재함.

### 06-2 Ansible Server

<img width="595" alt="스크린샷 2023-08-14 오후 7 42 06" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/bf40b526-ab36-406e-a12d-2948a7d3c9b6">

- 오픈 소스로서, 여러 개의 서버를 효율적으로 관리하기 위한 환경 구성 자동화 툴
- 자동화 대상에 연결 후, 명령을 실행하는 프로그램을 푸시하는 방식으로 작동. 이 프로그램은 SSH를 기반으로 실행되는 Ansible Module을 활용
- 자동화 task는 Playbook이라 불리는 청사진을 통해 정의됨. 이는 각 작업의 목록과 단계를 기술하며 서버의 상태를 원하는 대로 변경 및 관리 가능 
- 자동화 대상의 목록 또는 그룹을 지정한 inventory 파일을 통해 서버 식별 가능
- 동일 playbook을 몇 번이고 실행해도 같은 결과값을 얻을 수 있는 "멱등성"의 성질을 가지고 있음

***

## [ 07 VPN 구성 ]

***

## [ 08 Ansible Playbook 실행 과정 ]

#### 01 Ansbile Vault 생성 명령어
- ansible playbook 실행에 필요한 변수들을 vault를 통해 보호

<img width="576" alt="00_ansible_vault_create" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/6350f3c0-55a3-4d58-95af-8672f9c3c798">



#### 02 Ansible Playbook syntax check
- playbook 실행 전에 구성 문법 확인

<img width="768" alt="00_ansible-playbook-syntax-check" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/12b20578-3b9b-4ccb-9867-39910277fe1f">



#### 03 Ansible Client User 생성 playbook 실행
- ansible 관련 작업을 진행할 때, 하나의 user를 사용함으로써 권한이슈 및 관리의 효율성을 챙기기 위해

<img width="817" alt="01_ansible_playbook_result" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/72359d3d-4b93-4423-aa5e-68ebb1d607e4">



#### 04 Aws cli download playbook
- IDC 대상으로 한 playbook이지만, 구현 시 AWS EC2 Instance를 IDC로 구성했기 때문에 기본적으로 aws cli가 다운로드 되어 있으므로 생략


#### 05 압축 테스트를 위한 임의의 파일 생성

<img width="717" alt="02_app_data" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/51760c1c-fa20-40b8-bcb6-f3d0bbe6f4a4">


#### 06 파일 압축 + S3 bucket Upload Playbook 실행

<img width="815" alt="02_ansible_playbook_02_result_s3_sync" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/323138ec-3b8b-4783-b300-567a1a3f188b">


<img width="618" alt="02_result_tar_gz_data" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/234dde71-b2de-4d8e-8acd-31c118b33b73">

- .tar.gz format으로 idc 서버에 압축된 것을 확인할 수 있음


#### 07 S3 bucket 확인

<img width="1334" alt="03_ansible_playbook_result_final" src="https://github.com/heungbot/01_Ansible_VPN_On_Premise/assets/97264115/9782afa2-4947-4821-b395-68c4a5a033fc">

- 압축된 파일이 s3 bucket으로 잘 가져와짐을 확인
