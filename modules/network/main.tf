# /workspaces/AWS-Examples/modules/network/main.tf

resource "aws_vpc" "sri_quickbasket_vpc" {
  cidr_block = var.config.vpc_cidr
  tags = {
    Name="sri_quickbasket_vpc_${var.config.environment}"
    Environment = var.config.environment
  }
}
#udvyqycgqginfxqj
resource "aws_internet_gateway" "sri_quickbasket_igw" {
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  
  tags = {
    Name="sri_quickbasket_igw_${var.config.environment}"
  }
}

resource "aws_nat_gateway" "sri_quickbasket_ngw" {
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  availability_mode = "regional"
  tags = {
    Name="sri_quickbasket_ngw_${var.config.environment}"
  }
}

#ignore
#djzs kzmw zdpb sjnm

resource "aws_subnet" "sri_quickbasket_public" {
  count = length(var.config.public_subnets)
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  availability_zone = var.config.az[count.index]
  cidr_block = var.config.public_subnets[count.index]
  tags = {
        Name="Sri_quickbasket_public_${count.index + 1}_${var.config.environment}"
  }
}

resource "aws_route_table" "sri_quickbasket_public_RTB" {
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sri_quickbasket_igw.id
  }
  tags = {
    Name="sri_quickbasket_public_RTB_${var.config.environment}"
  }
}

resource "aws_route_table_association" "sri_quickbasket_public_RTB_Assoc" {
  count          = length(var.config.public_subnets)
  route_table_id = aws_route_table.sri_quickbasket_public_RTB.id
  subnet_id = aws_subnet.sri_quickbasket_public[count.index].id
}


resource "aws_subnet" "sri_FE_quickbasket_private" {
  count = length(var.config.FE_private_subnets)
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  availability_zone = var.config.az[count.index]
  cidr_block = var.config.FE_private_subnets[count.index]
  tags = {
    Name="sri_FE_quickbasket_private_${count.index + 1}_${var.config.environment}"
  }
}

resource "aws_route_table" "sri_FE_quickbasket_private_RTB" {
  vpc_id = aws_vpc.sri_quickbasket_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.sri_quickbasket_ngw.id
  }
  tags = {
    Name="sri_FE_quickbasket_private_RTB_${var.config.environment}"
  }
}

resource "aws_route_table_association" "sri_FE_quickbasket_private_RTB_Assoc" {
  count          = length(var.config.FE_private_subnets)
  route_table_id = aws_route_table.sri_FE_quickbasket_private_RTB.id
  subnet_id = aws_subnet.sri_FE_quickbasket_private[count.index].id
}



resource "aws_subnet" "sri_BE_quickbasket_private" {
    count = length(var.config.BE_private_subnets)
      vpc_id = aws_vpc.sri_quickbasket_vpc.id
        availability_zone = var.config.az[count.index]
          cidr_block = var.config.BE_private_subnets[count.index]
            tags = {
                  Name="sri_BE_quickbasket_private_${count.index + 1}_${var.config.environment}"
            }
}

resource "aws_route_table" "sri_BE_quickbasket_private_RTB" {
    vpc_id = aws_vpc.sri_quickbasket_vpc.id
      route {
            cidr_block = "0.0.0.0/0"
               nat_gateway_id   = aws_nat_gateway.sri_quickbasket_ngw.id
      }
        tags = {
              Name="sri_BE_quickbasket_private_RTB_${var.config.environment}"
        }
}

resource "aws_route_table_association" "sri_BE_quickbasket_private_RTB_Assoc" {
    count          = length(var.config.BE_private_subnets)
      route_table_id = aws_route_table.sri_BE_quickbasket_private_RTB.id
        subnet_id = aws_subnet.sri_BE_quickbasket_private[count.index].id
}


resource "aws_subnet" "sri_DB_quickbasket_private" {
    count = length(var.config.DB_private_subnets)
      vpc_id = aws_vpc.sri_quickbasket_vpc.id
        availability_zone = var.config.az[count.index]
          cidr_block = var.config.DB_private_subnets[count.index]
            tags = {
                  Name="sri_DB_quickbasket_private_${count.index + 1}_${var.config.environment}"
            }
}

