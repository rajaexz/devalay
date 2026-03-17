#!/usr/bin/env ruby

# Script to add dSYM generation build phase to Xcode project
# This fixes the missing Razorpay dSYM issue

require 'xcodeproj'

project_path = File.join(__dir__, '..', 'Runner.xcodeproj')
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'Runner' }

if target.nil?
  puts "❌ Runner target not found"
  exit 1
end

# Check if script phase already exists
existing_phase = target.shell_script_build_phases.find { |phase| phase.name == 'Generate Razorpay dSYM' }

if existing_phase
  puts "✅ dSYM generation script already exists"
  exit 0
end

# Create new shell script build phase
script_phase = target.new_shell_script_build_phase('Generate Razorpay dSYM')

# Set the script
script_path = File.join(__dir__, 'generate_razorpay_dsym.sh')
script_phase.shell_script = "\"#{script_path}\""

# Make it run after frameworks are embedded
# Find the "Embed Pods Frameworks" phase
embed_phase_index = target.shell_script_build_phases.find_index { |phase| phase.name == '[CP] Embed Pods Frameworks' }

if embed_phase_index
  # Insert after the embed phase
  target.build_phases.delete(script_phase)
  target.build_phases.insert(embed_phase_index + 1, script_phase)
end

# Save the project
project.save

puts "✅ Successfully added dSYM generation script to Xcode project"

