# Elastic IPS
resource "aws_eip" "persistent" {
  vpc = true

  tags = {
    Name     = "IP elastica"
    Episodio = "Api TuVoz"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_file_system" "persistent" {
  creation_token   = "InformeNube4"
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = {
    Name     = "EFS"
    Episodio = "Api TuVoz"
  }
}

resource "aws_efs_mount_target" "persistent" {
  count           = length(data.aws_availability_zones.available.zone_ids)
  file_system_id  = aws_efs_file_system.persistent.id
  subnet_id       = element(aws_subnet.privada.*.id, count.index)
  security_groups = [aws_security_group.efs.id]
}



resource "aws_instance" "persistent" {
  count = 1
  #availability_zone      = "eu-west-1b"
  ami                    = "ami-0d527b8c289b4af7f" // AMI son regionales (distintas IDS por region) instancia de ubuntu en la region de irlandia
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = concat([aws_security_group.servidor_web.id], [aws_security_group.efs.id], [aws_default_security_group.default.id])
  key_name               = aws_key_pair.laptop.id

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = true
  }

  user_data = local.user_data

  tags = {
    Name     = "EC2 con persistencia en ${aws_subnet.public[count.index].availability_zone}"
    Episodio = "Informe Nube"
  }


  depends_on = [aws_efs_file_system.persistent, aws_efs_mount_target.persistent]
}

resource "aws_eip_association" "persistent" {
  instance_id   = aws_instance.persistent[0].id
  allocation_id = aws_eip.persistent.id
}


