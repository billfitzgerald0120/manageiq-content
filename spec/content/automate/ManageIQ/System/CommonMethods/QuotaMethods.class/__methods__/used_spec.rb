require_domain_file

describe ManageIQ::Automate::System::CommonMethods::QuotaMethods::Used do
  include Spec::Support::QuotaHelper

  let!(:model) { setup_model }
  let(:root_hash) do
    {
      'miq_provision_request' => svc_miq_request,
      'miq_request'           => svc_miq_request,
      'quota_source'          => quota_source,
      'quota_source_type'     => quota_source_type
    }
  end

  let(:svc_miq_request) { MiqAeMethodService::MiqAeServiceMiqRequest.find(@miq_provision_request.id) }

  let(:active_counts_hash) do
    {:storage => 2_000_000, :cpu => 8, :count => 9, :memory => 6_000_000_000}
  end

  let(:result_counts_hash) do
    {:storage => 3_000_000, :cpu => 8, :vms => 11, :memory => 7_073_741_824}
  end

  let(:root_object) do
    Spec::Support::MiqAeMockObject.new(root_hash)
  end

  let(:ae_service) do
    Spec::Support::MiqAeMockService.new(root_object).tap do |service|
      current_object = Spec::Support::MiqAeMockObject.new
      current_object.parent = root_object
      service.object = current_object
    end
  end

  shared_examples_for "used" do
    it "check" do
      expect(svc_miq_request).to receive(:check_quota).with(active_method).and_return(active_counts_hash)
      described_class.new(ae_service).main
      expect(ae_service.root['quota_used']).to include(result_counts_hash)
    end
  end

  context "returns ok for tenant counts" do
    let(:quota_source) { MiqAeMethodService::MiqAeServiceTenant.find(@tenant.id) }
    let(:quota_source_type) { 'tenant' }
    let(:active_method) { 'active_provisions_by_tenant'.to_sym }

    it_behaves_like "used"
  end

  context "returns ok for user counts" do
    let(:quota_source) { MiqAeMethodService::MiqAeServiceUser.find(@user.id) }
    let(:quota_source_type) { 'user' }
    let(:active_method) { 'active_provisions_by_owner'.to_sym }

    it_behaves_like "used"
  end

  context "returns ok for group counts" do
    let(:quota_source) { MiqAeMethodService::MiqAeServiceMiqGroup.find(@miq_group.id) }
    let(:quota_source_type) { 'group' }
    let(:active_method) { 'active_provisions_by_group'.to_sym }

    it_behaves_like "used"
  end

  context "returns error " do
    let(:quota_source_type) { nil }
    let(:quota_source) { nil }
    let(:errormsg) { 'ERROR - quota_source not found' }

    it "when no quota source" do
      expect { described_class.new(ae_service).main }.to raise_error(errormsg)
    end
  end
end
