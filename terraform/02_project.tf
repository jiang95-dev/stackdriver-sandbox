# Here we are creating a project to contain the deployed resources. A couple of
# general terraform notes: this is the first time we're seeing the `data`
# stanza. This gives a way to look stuff up and use it in other resources. Here
# we're looking up the billing account by name (hence why the README has you
# name it a certain way) so we can pass its ID on later.
#
# If productized we'd drop this and use the default billing account instead.
data "google_billing_account" "acct" {
  display_name = "${var.billing_account}"
}

# This generates a random project id that starts with "stackdriver-sandbox-" and
# ends with a random number in the unsigned int range. See the docs for more:
# https://www.terraform.io/docs/providers/random/r/id.html
resource "random_id" "project" {
  prefix      = "stackdriver-sandbox-"
  byte_length = "4"
}

# Here we create the actual project.
resource "google_project" "project" {
  name = "Stackdriver Sandbox - demo environment for learning Stackdriver"

  # This references the random project ID we created above; note that we're
  # asking for the `dec` attribute which returns the number in decimal format
  project_id = "${random_id.project.dec}"

  # This references the billing account that we looked up before. Note the
  # `data.` prefix vs. using the resource name directly as we did above with
  # `random_id.`
  billing_account = "${data.google_billing_account.acct.id}"
}

resource "google_project_service" "iam" {
  project = "${google_project.project.id}"

  service = "iam.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "compute" {
  project = "${google_project.project.id}"

  service = "compute.googleapis.com"

  disable_dependent_services = true
}

# Enable GKE in the project we created. If you look at the docs you might see
# the `google_project_services` resource which allows you to specify a list of
# resources to enable. This seems like a good idea but there's a gotcha: to use
# that resource you have to specify a comprehensive list of services to be
# enabled for your project. Otherwise it will disable services you might be
# using elsewhere.
#
# For that reason, we use the single service option instead since it allows us
# granular control.
resource "google_project_service" "gke" {
  # This could just as easily reference `random_id.project.dec` but generally
  # you want to dereference the actual object you're trying to interact with.
  #
  # You'll see this line in every resource we create from here on out. This is
  # necessary because we didn't configure the provider with a project because
  # the project didn't exist yet. This could be refactored such that the project
  # was created outside of terraform, the provider configured with the project,
  # and then we don't have to specify this on every resource any more.
  #
  # Anyway, expect to see a lot more of these. I won't explain every time.
  project = "${google_project.project.id}"

  # the service URI we want to enable
  service = "container.googleapis.com"

  disable_dependent_services = true
}