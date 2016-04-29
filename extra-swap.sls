{% set swapfile = '/.salt-runtests.swapfile' %}

create-swap-file:
  {# because everytime a new subprocess.Popen() is instantiated, a copy of the current python
     interpreter memory is cloned. Yes, it's copy-on-write, however, due to python's refcount
     for garbage collection, copy-on-write's happen to often and we endup with getting out of
     memory errors in the tests suite.
     Let's see if this solves that issue.
  #}
  cmd.run:
    - name: 'fallocate -l 1024M /swapfile'
    - onlyif: '[ -a {{ swapfile }} ]'

make-swap:
  cmd.run:
    - name: mkswap {{ swapfile }}
    - onchanges:
      - cmd: create-swap-file


add-extra-swap:
  mount.swap:
    - name: {{ swapfile }}
    - persist: False
    - onchanges:
      - cmd: make-swap
