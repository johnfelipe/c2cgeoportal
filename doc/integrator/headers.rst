.. _integrator_headers:

Headers
=======

We can set with some configuration some HTTP headers on defferent path.
We do that with the ``global _headers`` from the configuration with the following syntax:

.. code:: yaml

    vars:
      global_headers:
        - pattern: <regex>
          headers:
            <header>: <value>

If a path match more than one pattern, all the headers will be applyed, if one header applyed tweice
the last one win.

For the ``Content-Security-Policy`` we add some vars to be customisable.
Thes vars follows the folowing pattern ``content_security_policy_<path>_<directive>[_extra]``.

Where ``<path>`` can be: ``main``, ``admin``, ``apihelp``, ``oldapihelp`` or ``c2c``,
``<directive>`` can be: ``default_src``, ``script_src``, `style_src``, ``img_src``,
``connect_src`` or ``worker_src``,
``[_extra]``is a suffix to be able to extend a directive instance of completely overide it.
