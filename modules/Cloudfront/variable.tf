

variable "cldfrnt_config" {
  description = "A combined object for all cloudfront configurations "
  type = object({
    environment = string
    quickbasket_img_fetch_s3_regional_domain_name=string
  })
}