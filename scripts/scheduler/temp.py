from oslo.config import cfg

from nova import db
from nova.openstack.common.gettextutils import _
from nova.openstack.common import log as logging
from nova.scheduler import filters

LOG = logging.getLogger(__name__)

temp_dict = {'sridhar':100,
            'dev':120,
            'local':140
            }
temp_thresh = 120

class BasicTempFilter(filters.BaseHostFilter):
    def _get_temp(self,host):
        
        return temp_dict[host]

    def host_passes(self, host_state, filter_properties):
        """Only return hosts which satisfy the temp properties"""
        host_name = host_state.host

        LOG.debug(_("%(host_state)s---------+++++++++++++++++------------------------------>>>>%(host_state1)s\n"),
                    {'host_state': host_state,'host_state1': host_state})
        
        temp = self._get_temp(host_name)
        if temp_thresh <= temp:
            LOG.debug(_("%(host_state)s does not have %(temp)s MB "
                    "usable ram, it only has %(temp_thresh)s MB usable ram."),
                    {'host_state': host_state,
                     'temp': temp,
                     'temp_thresh': temp_thresh})
            return False

        # save oversubscription limit for compute node to test against:
        return True


