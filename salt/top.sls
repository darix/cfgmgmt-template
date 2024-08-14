{% set roles = salt['pillar.get']('roles', []) %}

base:
  '*':
    - profile-base
  {% for role in roles %}
  'roles:{{ role }}':
    - match: pillar
    - roles.{{ role }}
  {% endfor %}

