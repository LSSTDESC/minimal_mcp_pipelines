import numpy as np
import sys
sys.path.insert(0, '/global/u1/j/jmena/TJPCov')
import tjpcov
print(tjpcov.__path__)
from tjpcov.covariance_calculator import CovarianceCalculator
import sacc

config_yml = f'config_wtheta_DESY6BAO.yml'
cc = CovarianceCalculator(config_yml)

print(cc.config)

s = sacc.Sacc.load_fits(cc.config['tjpcov']['sacc_file'])
print(s.get_data_types())

print('Running covariance!')

cov = cc.get_covariance()

print('Finished!')

np.savetxt(f'cov_tjpcov/cov_wtheta_DESY6BAO.txt', cov)
