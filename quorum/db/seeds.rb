room = LunchRoom.find_or_initialize_by(public_token: "builder-loft")
room.locked_candidate = nil
room.backup_candidate = nil
room.assign_attributes(
  name: "Lunch at Builder Loft",
  origin_text: "AWS Builder Loft, 525 Market St, San Francisco",
  lunch_at: Time.zone.parse("#{Date.current} 12:15"),
  return_by: Time.zone.parse("#{Date.current} 13:00"),
  group_budget_cents: 2_500,
  status: :collecting
)
room.save!

room.research_runs.destroy_all
room.participants.destroy_all

[
  { name: "Maya", diet: "Vegetarian", max_walk_minutes: 12, budget_cents: 2_500 },
  { name: "Jon", max_walk_minutes: 12, budget_cents: 2_000 },
  { name: "Leah", max_walk_minutes: 12, budget_cents: 2_500, hard_stop: Time.zone.parse("#{Date.current} 13:00") },
  { name: "Sam", dislikes: "Sushi", max_walk_minutes: 12, budget_cents: 2_500 }
].each { |attributes| room.participants.create!(attributes) }

run = room.research_runs.create!(
  status: :reasoning,
  provider: "demo",
  query: LunchResearch::PromptBuilder.new(room).query,
  started_at: Time.current
)
LunchResearch::DemoProvider.new(run).complete!

puts "Demo room: /rooms/#{room.public_token}"
