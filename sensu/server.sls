{% from "sensu/pillar_map.jinja" import sensu with context -%}

include:
  - sensu
  - sensu.api_conf # Some handlers need to access the API server
  - sensu.rabbitmq_conf
  - sensu.redis_conf

/etc/sensu/extensions:
  file.recurse:
    - source: salt://sensu/files/extensions
    - file_mode: 555
    - require:
      - pkg: sensu
    - watch_in:
      - service: sensu-server
   
/etc/sensu/mutators:
  file.recurse:
    - source: salt://sensu/files/mutators
    - file_mode: 555
    - require:
      - pkg: sensu
    - watch_in:
      - service: sensu-server

/etc/sensu/handlers:
  file.recurse:
    - source: salt://sensu/files/handlers
    - file_mode: 555
    - require:
      - pkg: sensu
    - require_in:
      - service: sensu-server
    - watch_in:
      - service: sensu-server

{% set gem_list = salt['pillar.get']('sensu:server:install_gems', []) %}
{% for gem in gem_list %}
install_{{ gem }}:
  gem.installed:
    - name: {{ gem }}
    - gem_bin: /opt/sensu/embedded/bin/gem
    - rdoc: False
    - ri: False
{% endfor %}

sensu-server:
  service.running:
    - enable: True
    - require:
      - file: /etc/sensu/conf.d/redis.json
      - file: /etc/sensu/conf.d/rabbitmq.json
