from distutils.core import setup
setup(name='mgcspendfrom',
      version='1.0',
      description='Command-line utility for carbonemissiontradecoin "coin control"',
      author='Gavin Andresen',
      author_email='gavin@carbonemissiontradecoinfoundation.org',
      requires=['jsonrpc'],
      scripts=['spendfrom.py'],
      )
