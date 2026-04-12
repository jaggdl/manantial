# Agent Notes

## Project: Manantial Latest

### Authentication Context

This application has two distinct concepts that are often confused:

**`Current.owner`**
- The blog owner (always `User.first`)
- Set for ALL visitors via `set_owner` before_action
- Used to identify the blog owner across the site
- Available even for unauthenticated visitors

**`authenticated?`**
- Helper method from `Authentication` concern
- Returns true only when user has an active session (logged in)
- Use this to check if current user is actually logged in
- Available as helper method in views and controllers

**When to use each:**
- Show owner info in header → `Current.owner`
- Check if user can create/edit posts → `authenticated?`
- Show admin actions → `authenticated?`
- Display owner profile/avatar → `Current.owner`

### Related Files
- `app/controllers/concerns/authentication.rb` - Authentication logic
- `app/models/current.rb` - Current attributes setup
