{% set roles = salt['pillar.get']('role', []) %}

base:
  '*':
    - profile-base
  {% for role in roles %}
  'roles:{{ role }}':
    - match: pillar
    - roles.{{ role }}
  {% endfor %}

