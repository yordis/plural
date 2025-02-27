import { A, Flex, Span } from 'honorable'
import { Toast } from '@pluralsh/design-system'

import BillingMigrationModal from '../account/billing/BillingMigrationModal'

import Sidebar from './Sidebar'
import WithApplicationUpdate from './WithApplicationUpdate'
import Header from './Header'
import Subheader from './Subheader'
import { ContentOverlay } from './Overlay'

function ApplicationLayout({ children }: any) {
  const isProduction = import.meta.env.MODE === 'production'

  return (
    <>
      <Flex
        position="relative"
        width="100vw"
        maxWidth="100vw"
        height="100vh"
        minWidth="0"
        minHeight="0"
        maxHeight="100vh"
        overflow="hidden"
        flexDirection="column"
      >
        {isProduction && (
          <WithApplicationUpdate>
            {({ reloadApplication }) => (
              <Toast
                severity="info"
                marginBottom="medium"
                marginRight="xxxxlarge"
              >
                <Span marginRight="small">Time for a new update!</Span>
                <A
                  onClick={() => reloadApplication()}
                  style={{ textDecoration: 'none' }}
                  color="action-link-inline"
                >
                  Update now
                </A>
              </Toast>
            )}
          </WithApplicationUpdate>
        )}
        <Header />
        <Flex
          width="100%"
          minWidth={0}
          minHeight={0}
          flexGrow={1}
        >
          <Sidebar />
          <Flex
            direction="column"
            flexGrow={1}
            overflowX="hidden"
            position="relative"
          >
            <ContentOverlay />
            <Subheader />
            {children}
          </Flex>
        </Flex>
      </Flex>
      <BillingMigrationModal />
    </>
  )
}

export default ApplicationLayout
