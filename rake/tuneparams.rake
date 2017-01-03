require 'rake'
params_to_tune = %w(alpha lambda)
group_by = %w(finalholdout)
error_value = 'mean_diff'
ptt = params_to_tune.collect {|x| "-p #{x}"}.join(' ')
gb = group_by.collect {|x| "-b #{x}"}.join(' ')
ev = "-e #{error_value}"
args = [ptt,gb,ev,'--maximize','--quiet'].join(' ')

SWEEPFILES = Dir['*'].select {|x| x=~ /.*_tune[0-9]*.csv/}
PARAMFILES = SWEEPFILES.collect {|f| f.sub(/_tune([0-9]*).csv/,'_params\1.csv')}

PARAMFILES.zip(SWEEPFILES).each do |target,source|
  file target => source do
    sh("identify_best_parameters.R #{args} #{source} > #{target}")
  end
end

task :default => PARAMFILES
