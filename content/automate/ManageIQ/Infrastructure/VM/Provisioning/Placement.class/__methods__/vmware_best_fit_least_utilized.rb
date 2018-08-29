#
# Description: This method is used to find all hosts, datastores that are the least utilized
#
module ManageIQ
  module Automate
    module Infrastructure
      module VM
        module Provisioning
          module Placement
            class VmwareBestFitLeastUtilized
              def initialize(handle = $evm)
                @handle = handle
              end

              def main
                @handle.log("info", "vm=[#{vm.name}], space required=[#{vm.provisioned_storage}]")
                best_fit_least_utilized
              end

              private

              def request
                @request ||= @handle.root["miq_provision"].tap do |req|
                  log_and_raise('miq_provision not specified') if req.nil?
                end
              end

              def vm
                @vm ||= request.vm_template.tap do |vm|
                  log_and_raise('VM not specified') if vm.nil?
                end
              end

              def best_fit_least_utilized
                host = storage = min_registered_vms = nil
                request.eligible_hosts.select { |h| !h.maintenance && h.power_state == "on" }.each do |h|
                  next if min_registered_vms && h.vms.size >= min_registered_vms
                  storages = h.writable_storages.find_all { |s| s.free_space > vm.provisioned_storage } # Filter out storages that do not have enough free space for the Vm

                  s = storages.max_by(&:free_space)
                  next if s.nil?
                  host    = h
                  storage = s
                  min_registered_vms = h.vms.size
                end

                # Set host and storage
                request.set_host(host) if host
                request.set_storage(storage) if storage

                @handle.log("info", "vm=[#{vm.name}] host=[#{host}] storage=[#{storage}]")
              end

              def log_and_raise(message)
                @handle.log(:error, message)
                raise "ERROR - #{message}"
              end
            end
          end
        end
      end
    end
  end
end

ManageIQ::Automate::Infrastructure::VM::Provisioning::Placement::VmwareBestFitLeastUtilized.new.main
