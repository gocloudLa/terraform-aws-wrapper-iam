/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* IAM | Variable Definition                                            */
/*----------------------------------------------------------------------*/
variable "iam_parameters" {
  type        = any
  description = "IAM parameters to configure IAM module"
  default     = {}
}

variable "iam_defaults" {
  type        = any
  description = "IAM default parameters to configure IAM module"
  default     = {}
}
