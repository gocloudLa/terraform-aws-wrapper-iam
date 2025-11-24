/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

/*----------------------------------------------------------------------*/
/* IAM | Variable Definition                                            */
/*----------------------------------------------------------------------*/
variable "iam_parameters" {
  type        = any
  description = "iam parameteres to configure iam module"
  default     = {}
}

variable "iam_defaults" {
  type        = any
  description = "iam parameteres to configure iam module"
  default     = {}
}
