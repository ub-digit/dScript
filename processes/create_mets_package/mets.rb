module CreateMETSPackage
  class METS
    def initialize(job)
      @job = job
    end

    def mets_data
      {
        id: sprintf("GUB%07d", @job['id'].to_i),
        created_at: @job['created_at'],
        updated_at: @job['updated_at'],
        creator_sigel: CreateMETSPackage::CREATOR[:sigel],
        creator_name: CreateMETSPackage::CREATOR[:name],
        archivist_sigel: CreateMETSPackage::ARCHIVIST[:sigel],
        archivist_name: CreateMETSPackage::ARCHIVIST[:name],
        copyright_status: CreateMETSPackage::COPYRIGHT_STATUS[@job['copyright']],
        publication_status: CreateMETSPackage::PUBLICATION_STATUS[@job['copyright']]
      }
    end

    def head
      %Q{<mets:metsHdr ID="#{mets_data[:id]}"
                     CREATEDATE="#{mets_data[:created_at]}" LASTMODDATE="#{mets_data[:updated_at]}"
                     RECORDSTATUS="complete">
        <mets:agent ROLE="CREATOR" TYPE="ORGANIZATION" ID="#{mets_data[:creator_sigel]}">
         <mets:name>#{mets_data[:creator_name]}</mets:name>
        </mets:agent>
        <mets:agent ROLE="ARCHIVIST" TYPE="ORGANIZATION" ID="#{mets_data[:archivist_sigel]}">
         <mets:name>#{mets_data[:archivist_name]}</mets:name>
        </mets:agent>
       </mets:metsHdr>}
    end

    def administrative
      %Q(<mets:amdSec ID="amdSec1" >
        <mets:rightsMD ID="rightsDM1">
         <mets:mdWrap MDTYPE="OTHER">
          <mets:xmlData>
           <copyright copyright.status="#{mets_data[:copyright_status]}" publication.status="#{mets_data[:publication_status]}" xsi:noNamespaceSchemaLocation="http://www.cdlib.org/groups/rmg/docs/copyrightMD.xsd"/>
          </mets:xmlData>
         </mets:mdWrap>
        </mets:rightsMD>
       </mets:amdSec>)
    end
  end
end
