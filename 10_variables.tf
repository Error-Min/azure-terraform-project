/*===============cd===============resource_group 설정=======3=============================*/
variable "resource_group_name" {
   description = "resource group Name"
   default     = "smt030"
   # (1) 리소스 그룹 이름 변수
}

variable "location" {
   default = "korea central"
   description = "Location where resources"
   # (2) 리소스 그룹 리전 korea central -> 서울 중부
}
/*==============================resource_group 설정====================================*/
/*=================================root 계정및 암호====================================*/
variable "admin_user" {
    # VM 스케일 세트의 일부가 될 VM의 관리자 계정으로 사용할 사용자 이름
   default     = "azureuser"
   # (5)
}

variable "admin_password" {
   # admin(root) 계정 암호
   default = "#Rlflqhdl21"
   # (6)
}
/*=================================root 계정및 암호====================================*/
/*=====================================리소스 네임====================================*/
variable "resource_names" {
   default = "errormin"
}
/*=====================================리소스 네임====================================*/




variable "application_port" {
    #외부 로드 밸런서에 노출할 포트
   default     = 80
   # (4) 로드 벨런서 외부
}














#========================================================================
#===============================태그모음==================================
#========================================================================

variable "tags" {
   type        = map(string)
   default = {
      environment = "sangmin"
   }
   # (3) 태그
}

variable "vmsstags" {
   type        = map(string)
   default = {
      environment = "vmsssmt070"
   }
   # (3) 태그
}


variable "vmtags" {
   type        = map(string)
   default = {
      environment = "vmsmt030"
   }
   # (3) 태그
}

variable "lbtags" {
   type        = map(string)
   default = {
      environment = "lbsmt030"
   }
   # (3) 태그
}