variable "region"{
    default = "ap-south-1"
    type = "string"
}
variable "prof"{
    default = "default"
    type = "string"
}
variable "range"{
    default = "10.0.0.0/16"
    type = "string"
}
variable "vpctag"{
    default = "clustervpc"
    type = "string"
}
variable "subrange"{
    default = "10.0.1.0/24"
    type = "string"
}
variable "zones"{
    default = "ap-south-1a"
    type = "string"
}
variable "subnettag"{
    default = "publicsb"
    type = "string"
}
variable "igtag"{
    default = "cluster_gw"
    type = "string"
}
variable "rtag"{
    default = "main_rt"
    type = "string"
}
variable "sgname"{
    default = "cluster_sg"
    type = "string"
}
variable "amiid"{
    default = "ami-010aff33ed5991201"
    type = "string"
}
variable "ec2type"{
    default = "t2.micro"
    type = "string"
}
variable "keyname"{
    default = "key17"
    type = "string"
}
variable "hdfs_master"{
    default = "namenode"
    type = "string"
}
variable "hdfs_slavecount"{
    default = "2"
    type = "string"
}
variable "mapred_master"{
    default = "jobtracker"
    type = "string"
}
variable "mr_slavecount"{
    default = "2"
    type = "string"
}
variable "hdfs_slave"{
    default = "datanode"
    type = "string"
}
variable "mapred_slave"{
    default = "tasktracker"
    type = "string"
}
variable "client"{
    default = "client"
    type = "string"
}





