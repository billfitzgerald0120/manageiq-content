describe 'vmmigratetask_complete method' do
  let(:miq_server)       { EvmSpecHelper.local_miq_server }
  let(:user)             { FactoryBot.create(:user_with_email_and_group) }
  let(:miq_request_task) { FactoryBot.create(:miq_request_task, :miq_request => request, :source => vm) }
  let(:request)          { FactoryBot.create(:vm_migrate_request, :requester => user) }

  let(:ems)              { FactoryBot.create(:ems_vmware, :tenant => Tenant.root_tenant) }
  let(:vm)               { FactoryBot.create(:vm_vmware, :ems_id => ems.id, :evm_owner => user) }

  it 'sends email' do
    expect(GenericMailer).to receive(:deliver).with(:automation_notification,
                                                    hash_including(:to   => user.email,
                                                                   :from => "evmadmin@example.com"))
    attrs = ["MiqServer::miq_server=#{miq_server.id}"]
    attrs << "MiqRequestTask::vm_migrate_task=#{miq_request_task.id}"
    attrs << "vm_migrate_task_id=#{miq_request_task.id}"
    MiqAeEngine.instantiate("/Infrastructure/VM/Migrate/Email/VmMigrateTask_Complete?event=vm_migrated&#{attrs.join('&')}", user)
  end

  it 'expect email not to be sent' do
    expect(GenericMailer).not_to receive(:deliver).with(:automation_notification,
                                                        hash_including(:to   => nil,
                                                                       :from => "evmadmin@example.com"))
    attrs = ["MiqServer::miq_server=#{miq_server.id}"]
    attrs << "MiqRequestTask::vm_migrate_task=#{miq_request_task.id}"
    attrs << "vm_migrate_task_id=#{miq_request_task.id}"
    MiqAeEngine.instantiate("/Infrastructure/VM/Migrate/Email/VmMigrateTask_Complete?event=vm_migrated&#{attrs.join('&')}", user)
  end

  it 'sends email to nil' do
    expect(GenericMailer).not_to receive(:deliver).with(:automation_notification,
                                                        hash_including(:to   => nil,
                                                                       :from => "evmadmin@example.com"))
    attrs = ["MiqServer::miq_server=#{miq_server.id}"]
    attrs << "MiqRequestTask::vm_migrate_task=#{miq_request_task.id}"
    attrs << "vm_migrate_task_id=#{miq_request_task.id}"
    MiqAeEngine.instantiate("/Infrastructure/VM/Migrate/Email/VmMigrateTask_Complete?event=vm_migrated&#{attrs.join('&')}", user)
  end
end
