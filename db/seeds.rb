# Demo data: two authors, a few posts, comments, and votes.
# Run with `bin/rails db:seed`. Safe to run more than once.
alice = User.find_or_create_by!(username: "alice") do |user|
  user.email = "alice@example.com"
  user.password = "password123"
end

bob = User.find_or_create_by!(username: "bob") do |user|
  user.email = "bob@example.com"
  user.password = "password123"
end

welcome = alice.blogs.find_or_create_by!(title: "Welcome to the blog") do |blog|
  blog.body = "A first post to show the API in action."
  blog.tags = %w[intro]
end

tips = bob.blogs.find_or_create_by!(title: "Writing acceptance criteria") do |blog|
  blog.body = "Given, When, Then keeps every story testable."
  blog.tags = %w[product agile]
end

alice.blogs.find_or_create_by!(title: "Draft ideas") do |blog|
  blog.body = "Only Alice can see this until it is published."
  blog.status = "draft"
end

welcome.comments.find_or_create_by!(user: bob, body: "Nice start!")
tips.comments.find_or_create_by!(user: alice, body: "Adding this to our team guide.")

Vote.find_or_create_by!(user: bob, blog: welcome) { |vote| vote.value = 1 }
Vote.find_or_create_by!(user: alice, blog: tips) { |vote| vote.value = 1 }
