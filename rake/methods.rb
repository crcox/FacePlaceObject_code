def configure_afni_figure(funcfile,scalemax,threshold,sign)
  sh("plugout_drive -com 'RESCAN_THIS' -quit")
  sh("plugout_drive -com 'SET_FUNCTION #{funcfile}' -quit")
  sh("plugout_drive -com 'SET_FUNC_RANGE #{scalemax}' -quit")
  sh("plugout_drive -com 'SET_THRESHNEW #{threshold}' -quit")
  sh("plugout_drive -com 'SET_PBAR_SIGN #{sign}' -quit")
end

def configure_afni_figure_continuous(funcfile,scalemax,threshold,sign,colorscale_name)
  sh("plugout_drive -com 'RESCAN_THIS' -quit")
  sh("plugout_drive -com 'SET_FUNCTION #{funcfile}' -quit")
  sh("plugout_drive -com 'SET_PBAR_ALL #{sign}99 1.0 #{colorscale_name}' -quit")
  sh("plugout_drive -com 'SET_FUNC_RANGE #{scalemax}' -quit")
  sh("plugout_drive -com 'SET_THRESHNEW #{threshold}' -quit")
  sh("plugout_drive -com 'SET_PBAR_SIGN #{sign}' -quit")
end

def drive_afni_suma_record_figures(dirname,prefix)
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.left.ppm' -key:d 'ctrl+left' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.right_medial.ppm' -key:d '[' -key 'ctrl+r' -key:d '['")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.bottom.ppm' -key:d 'ctrl+down' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.right.ppm' -key:d 'ctrl+right' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.left_medial.ppm' -key:d ']' -key 'ctrl+r' -key:d ']'")
  sh("DriveSuma -com viewer_cont -key:r17 'right'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.back.ppm' -key:d 'right' -key 'ctrl+r'")
end

def compose_montage_figure(dirname,prefix)
  sh("/home/chris/src/Manchester_SoundPicture/rake/compose_montage_figure.sh #{dirname} #{prefix}")
  sh("mogrify -format png #{prefix}.ppm")
end

def png_threshold(target, source, threshold=0, scalemax=0, sign='-', colorscale_name="red_to_blue")
  spath = File.dirname(source).to_s
  prefix = target.sub('.png','')

  funcfile = File.basename(source)

  if (!(spath.eql? '.')) then
    sh("3dcopy #{source} #{funcfile}")
  end

  configure_afni_figure_continuous(funcfile,scalemax,threshold,sign,colorscale_name)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

  if (!(spath.eql? '.')) then
    rm_f(funcfile)
    rm_f(funcfile.sub(".HEAD",".BRIK"))
    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
  end
end

def png_ttest(target, source, threshold=0, scalemax=0, sign='-', colorscale_name="red_to_blue")
  spath = File.dirname(source).to_s
  prefix = target.sub('.png','')

  funcfile = File.basename(source)

  if (!(spath.eql? '.')) then
    sh("3dcopy #{source} #{funcfile}")
  end

  if threshold.is_a? String then
    pq = threshold[0]
    val = threshold[1..-1].to_f / 100
    threshold = "#{val} *#{pq}"
  end

  configure_afni_figure_continuous(funcfile,scalemax,threshold,sign,colorscale_name)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

  if (!(spath.eql? '.')) then
    rm_f(funcfile)
    rm_f(funcfile.sub(".HEAD",".BRIK"))
    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
  end
end

def png_binomrank(target, source)
  spath = File.dirname(source).to_s
  prefix = target.sub('.png','')

  funcfile = File.basename(source)

  if (!(spath.eql? '.')) then
    sh("3dcopy #{source} #{funcfile}")
  end

  scalemax = 0  # autorange
  if target.include? "p05" then
    threshold="0.05 *p"
  elsif target.include? "p01" then
    threshold="0.01 *p"
  elsif target.include? "p001" then
    threshold="0.001 *p"
  elsif target.include? "p0001" then
    threshold="0.0001 *p"
  elsif target.include? "p00001" then
    threshold="0.00001 *p"
  end
  sign = '+'
  configure_afni_figure(funcfile,scalemax,threshold,sign)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

  if (!(spath.eql? '.')) then
    rm_f(funcfile)
    rm_f(funcfile.sub(".HEAD",".BRIK"))
    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
  end
end

def png_nonparametric(target, source)
  prefix = target.sub('.png','')
  funcfile = source

#  if (!(spath.eql? '.')) then
#    sh("3dcopy #{source} #{funcfile}")
#  end

  if target.include? "p05" then
    threshold="0.05 *p"
  elsif target.include? "p01" then
    threshold="0.01 *p"
  elsif target.include? "p001" then
    threshold="0.001 *p"
  elsif target.include? "q05" then
    threshold="0.05 *q"
  elsif target.include? "q01" then
    threshold="0.01 *q"
  elsif target.include? "q001" then
    threshold="0.001 *q"
  end

  sign = '+'
  scalemax = 0  # autorange
  configure_afni_figure(funcfile,scalemax,threshold,sign)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

#  if (!(spath.eql? '.')) then
#    rm_f(funcfile)
#    rm_f(funcfile.sub(".HEAD",".BRIK"))
#    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
#  end
end

def afni_start(surfvol,spec)
  # sh() uses /bin/sh
  # system() uses either the system's default shell or the shell from which
  # rake was called (not sure which).
  system("afni -niml -yesplugouts &")
  sh("plugout_drive -com 'SWITCH_ANATOMY #{surfvol}' -quit")
  sh("plugout_drive -com 'SET_THRESHNEW 0' -quit")
  sh("plugout_drive -com 'SET_PBAR_SIGN -' -quit")
  sh("plugout_drive -com 'SEE_OVERLAY +' -quit")

  if ENV['SESSION']
    sh("plugout_drive -com 'SET_SESSION #{ENV['SESSION']}' -quit")
  end

  system("suma -niml -spec #{spec} -sv #{surfvol} &")
  sh("DriveSuma -com  viewer_cont -key:d 't'")           # talk to afni
  sh("DriveSuma -com  viewer_cont -key:r2 '.'")          # Select the inflated surfaces
  sh("DriveSuma -com  viewer_cont -key 'F3'")            # toggle the crosshair (off)
  sh("DriveSuma -com  viewer_cont -key 'F6'")            # toggle background color (to white from black)
  sh("DriveSuma -com  viewer_cont -key 'F9'")            # toggle the label at the crosshair (off)
  sh("DriveSuma -com  viewer_cont -viewer_size 700 600") # adjust viewer size (which effects figure size)
end

def afni_stop()
  sh("DriveSuma -com kill_suma")
  sh("plugout_drive -com 'QUIT' -quit")
end

def afni_undump(target, source, anat, orient='')
  target_prefix = target.split("+").first
  if orient.empty? then
    sh("3dUndump -master #{anat} -xyz -datum float -prefix #{target_prefix} #{source}")
  else
    sh("3dUndump -master #{anat} -xyz -orient #{orient} -datum float -prefix #{target_prefix} #{source}")
  end
end

def afni_maskdump(target, source, mask)
  begin
    sh("3dmaskdump -mask #{mask} -index -xyz -o #{target} #{source}")
  rescue
    puts "There are zero non-zero voxels in #{source}, #{target} will be empty."
    touch target
  end
end

def afni_scale(target, source, multiple=1)
  target_prefix = target.split("+").first
  sh("3dcalc -a #{source} -expr 'a*#{multiple}' -prefix #{target_prefix}")
end

def afni_deoblique(target, source)
  target_prefix = target.split("+").first
  sh("3dWarp -deoblique -prefix #{target_prefix} #{source}")
end

def afni_adwarp(source, reference, voxdim=3)
  sh("adwarp -apar #{reference} -dpar #{source} -dxyz #{voxdim}")
end

def afni_mean(target, source_list, blur=0)
  target_prefix = target.split("+").first
  if blur > 0 then
    sh("3dmerge -1blur_fwhm #{blur} -gmean -prefix #{target_prefix} #{source_list.join(' ')}")
  else
    sh("3dmerge -gmean -prefix #{target_prefix} #{source_list.join(' ')}")
  end
end

def afni_ttest(target, source_list, blur=0)
  target_prefix, target_ext = target.split('+',2)
  if blur > 0 then
    Dir.mktmpdir do |dir|
      source_list_prefix = source_list.collect {|x| x.split('+').first}
      source_list_blur_prefix = source_list_prefix.collect {|x| File.join(dir,"#{File.basename(x)}_b#{blur}")}
      source_list_blur = source_list_blur_prefix.collect {|x| [x,target_ext].join('+')}
      source_list_blur_prefix.zip(source_list).each do |blurred, source|
        sh("3dmerge -1blur_fwhm #{blur} -prefix #{blurred} #{source}")
      end
      sh("3dttest++ -setA #{source_list_blur.join(' ')} -prefix #{target_prefix}")
    end
  else
    sh("3dttest++ -setA #{source_list.join(' ')} -prefix #{target_prefix}")
  end
end

def afni_statmask(target, source, threshold, sign='-')
  target_prefix = target.split('+').first
  if threshold.is_a? String then
    pq = threshold[0]
    val = threshold[1..-1].to_f / 100
    threshold = "#{val} *#{pq}"
  end
  if sign == '+'
    noneg='-1noneg'
  end
  sh("3dmerge -1thresh '#{threshold}' #{noneg} -prefix #{target_prefix} #{source}")
end


def afni_signcount(target, source_list, blur=0)
  target_prefix, target_ext = target.split('+',2)
  Dir.mktmpdir do |dir|
    pos_full = File.join(dir,['pos',target_ext].join('+'))
    pos_prefix = File.join(dir,'pos')
    neg_full = File.join(dir,['neg',target_ext].join('+'))
    neg_prefix = File.join(dir,'neg')
    overlap_full = File.join(dir,['overlap',target_ext].join('+'))
    overlap_prefix = File.join(dir,'overlap')
    proportion_full = File.join(dir,['proportion',target_ext].join('+'))
    proportion_prefix = File.join(dir,'proportion')
    if blur > 0 then
      blur_arg = "-1blur_fwhm #{blur}"
    else
      blur_arg = ""
    end
    sh("3dmerge #{blur_arg} -gcount -prefix #{overlap_prefix} #{source_list.join(' ')}")
    sh("3dmerge #{blur_arg} -1noneg -gcount -prefix #{pos_prefix} #{source_list.join(' ')}")
    sh("3dmerge #{blur_arg} -2clip 0 99999 -gcount -prefix #{neg_prefix} #{source_list.join(' ')}")
    if File.file?(neg_full) then
      sh("3dcalc -a #{pos_full} -b #{neg_full} -c #{overlap_full} -expr '((a+0.0001)/(a+b+0.0001))*step(c)' -prefix #{proportion_prefix}")
    else
      sh("3dcalc -a #{pos_full} -c #{overlap_full} -expr '((a+0.0001)/(a+0+0.0001))*step(c)' -prefix #{proportion_prefix}")
    end
    sh("3dbucket -fbuc -prefix #{target_prefix} #{proportion_full} #{overlap_full}")
  end
  sh("3drefit -fith #{target}")
end

def afni_overlap(target, source_list, blur=0)
  target_prefix = target.split("+").first
  if blur > 0 then
    sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  else
    sh("3dmerge -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  end
  sh("3drefit -fim #{target}")
end

def afni_sd(target, mean, source_list, blur=0)
  target_prefix, target_ext = target.split('+',2)
  Dir.mktmpdir do |dir|
    variance_prefix = File.join(dir,'variance')
    variance_full = [variance_prefix,target_ext].join('+')
    squarederror_list = []

    source_list.each do |source|
      source_prefix, source_ext = source.split('+', 2)
      source_prefix_b  = File.basename(source_prefix)
      squarederror_prefix = File.join(dir,['sqerr',source_prefix_b].join('_'))
      squarederror_full = [squarederror_prefix,target_ext].join('+')

      if blur > 0
        bsource_prefix = File.join(dir,['b',source_prefix_b].join('_'))
        bsource_full = [bsource_prefix,source_ext].join('+')
        sh("3dmerge -1blur_fwhm #{blur} -prefix #{bsource_prefix} #{source}")
        sh("3dcalc -a #{bsource_full} -b #{mean} -expr '(a-b)*(a-b)' -prefix #{squarederror_prefix}")
      else
        sh("3dcalc -a #{source} -b #{mean} -expr 'step(a-b)' -prefix #{squarederror_prefix}")
      end

      squarederror_list.push(squarederror_full)
    end
    sh("3dmerge -gmean -prefix #{variance_prefix} #{squarederror_list.join(" ")}")
    sh("3dcalc -a #{variance_full} -expr 'sqrt(a)' -prefix #{target_prefix}")
  end
end

def afni_count(target, source_list, blur=0)
  target_prefix = target.split("+").first
  if blur then
    sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  else
    sh("3dmerge -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  end
end

def afni_blur(target, source, blur)
  target_prefix = target.split("+").first
  sh("3dmerge -1blur_fwhm #{blur} -prefix #{target_prefix} #{source}")
end

def binomrank_test(target, source_list, perm_lol, mask, blur: 0, prob: 0.5, overlap: false, scale: false)
  # source_list will contain a file for each subject.
  # perm_lol will contain a list of each permutation, each containing a list of
  # files for each subject.
  # If a blur option is passed, then temporary blurred versions of the source
  # and permutation files are generated and the rank is computed wrt those
  # blurred datasets. These blurred datasets are deleted after use.
  target_prefix, target_ext = target.split('+')
  #nsubj = source_list.size
  nperm = perm_lol.size
  Dir.mktmpdir do |dir|
    pcount_full_list = (1..perm_lol.size).collect {|i| File.join(dir,["pcount_#{i}",target_ext].join('+'))}
    pcount_prefix_list = (1..perm_lol.size).collect {|i| File.join(dir,"pcount_#{i}")}
    pmax_full = File.join(dir,['pmax',target_ext].join('+'))
    pmax_prefix = File.join(dir,'pmax')
    nzcount_full = File.join(dir,['nzcount',target_ext].join('+'))
    nzcount_prefix = File.join(dir,'nzcount')
    dump_mask_full = File.join(dir,['dump_mask',target_ext].join('+'))
    dump_mask_prefix = File.join(dir,'dump_mask')
    permdump = File.join(dir,'permdump.txt')
    meandump = File.join(dir,'meandump.txt')
    statdump = File.join(dir,'statdump.txt')
    parametric_pvals_full = File.join(dir,['parametric_pvals',target_ext].join('+'))
    parametric_pvals_prefix = File.join(dir,'parametric_pvals')
    parametric_pvals_filled_full = File.join(dir,['parametric_pvals_filled',target_ext].join('+'))
    parametric_pvals_filled_prefix = File.join(dir,'parametric_pvals_filled')
    thresh_full = File.join(dir,['thresh',target_ext].join('+'))
    thresh_prefix = File.join(dir,'thresh')
    mean_full = File.join(dir,['mean',target_ext].join('+'))
    mean_prefix = File.join(dir,'mean')
    mean_masked_full = File.join(dir,['mean_masked',target_ext].join('+'))
    mean_masked_prefix = File.join(dir,'mean_masked')
    mean_scaled_full = File.join(dir,['mean_scaled',target_ext].join('+'))
    mean_scaled_prefix = File.join(dir,'mean_scaled')
    count_full = File.join(dir,["count",target_ext].join('+'))
    count_prefix = File.join(dir,"count")
    bucket_full = File.join(dir,["bucket",target_ext].join('+'))
    bucket_prefix = File.join(dir,"bucket")
    #rank_full = File.join(dir,["rank",target_ext].join('+'))
    #rank_prefix = File.join(dir,"rank")
    #binom_pval_full = File.join(dir,["binom_pval",target_ext].join('+'))
    #binom_pval_prefix = File.join(dir,"binom_pval")
    ltreal_full = File.join(dir,["ltreal",target_ext].join('+'))
    ltreal_prefix = File.join(dir,"ltreal")
    ltcount_full = File.join(dir,["ltcount",target_ext].join('+'))
    ltcount_prefix = File.join(dir,"ltcount")
    eqreal_full = File.join(dir,["eqreal",target_ext].join('+'))
    eqreal_prefix = File.join(dir,"eqreal")
    eqcount_full = File.join(dir,["eqcount",target_ext].join('+'))
    eqcount_prefix = File.join(dir,"eqcount")

    pcount_prefix_list.zip(perm_lol).each do |prefix,perm_list|
      if (blur > 0)
        if overlap
          sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{prefix} #{perm_list.join(' ')}")
        else
          sh("3dmerge -1blur_fwhm #{blur} -gmean -prefix #{prefix} #{perm_list.join(' ')}")
        end
      else
        if overlap
          sh("3dmerge -gcount -prefix #{prefix} #{perm_list.join(' ')}")
        else
          sh("3dmerge -gmean -prefix #{prefix} #{perm_list.join(' ')}")
        end
      end
    end

    if blur > 0
      sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{count_prefix} #{source_list.join(' ')}")
      sh("3dmerge -1blur_fwhm #{blur} -gmean -prefix #{mean_prefix} #{source_list.join(' ')}")
    else
      sh("3dmerge -gcount -prefix #{count_prefix} #{source_list.join(' ')}")
      sh("3dmerge -gmean -prefix #{mean_prefix} #{source_list.join(' ')}")
    end

    # Combine permutation voxel selection datasets into a single dataset
    # N.B. the variable pcount_full_list is used regardless of whether we are
    # considering magnitudes or counts... which is confusing, but that's how it
    # is for now. So do not worry that this only corresponds to counts. It may
    # correspond to magnitudes if overlap: false.
    sh("3dbucket -fbuc -prefix #{bucket_prefix} #{pcount_full_list.join(' ')}")
    sh("3dmerge -gsmax -prefix #{pmax_prefix} #{pcount_full_list.join(' ')}")
    sh("3dmerge -gcount -prefix #{nzcount_prefix} #{pcount_full_list.join(' ')}")

    if overlap
      # Flag voxels in permutations where the real value at that voxel is larger.
      sh("3dcalc -prefix #{ltreal_prefix} -a #{count_full} -b #{bucket_full} -expr 'ispositive(a-b)'")
      # Flag voxels in permutations where the real value at that voxel is equal.
      sh("3dcalc -prefix #{eqreal_prefix} -a #{count_full} -b #{bucket_full} -expr 'equals(a,b)'")
    else
      # Flag voxels in permutations where the real value at that voxel is larger.
      sh("3dcalc -prefix #{ltreal_prefix} -a #{mean_full} -b #{bucket_full} -expr 'ispositive(a-b)'")
      # Flag voxels in permutations where the real value at that voxel is equal.
      sh("3dcalc -prefix #{eqreal_prefix} -a #{mean_full} -b #{bucket_full} -expr 'equals(a,b)'")
    end
    # Count the number of permutations that the real value is greater.
    sh("3dTstat -nzcount -prefix #{ltcount_prefix} #{ltreal_full}")
    # Count the number of permutations that the real value is equal (ties).
    sh("3dTstat -nzcount -prefix #{eqcount_prefix} #{eqreal_full}")
    # Compute the rank (number of values less than the real value + half the
    # number of ties with the real value)
    sh("3dcalc -prefix #{thresh_prefix} -a #{ltcount_full} -b #{eqcount_full} -c #{mask} -expr '(a+(b/2))*step(c)'")
    sh("3dcalc -prefix #{mean_masked_prefix} -a #{mean_full} -b #{mask} -expr 'a*step(b)'")

    # dumps for matlab
    dump_min_nnz = 30
    dump_thresh = 99.9
    sh("3dcalc -a #{nzcount_full} -b #{thresh_full} -expr 'ispositive(a-#{dump_min_nnz}) * ispositive(b-#{dump_thresh})' -prefix #{dump_mask_prefix}")
    sh("3dmaskdump -mask #{dump_mask_full} -o #{permdump} #{bucket_full}")
    sh("3dmaskdump -mask #{dump_mask_full} -o #{meandump} #{mean_masked_full}")
    if overlap
      # Fit a poisson when possible
      #sh("matlab -nojvm -r \"poissonfit('#{permdump}','#{meandump}','#{statdump}');exit\"")
    else
      # Fit a gamma when possible
      sh("gammafit.R #{permdump} #{meandump} #{statdump}")
      #sh("matlab -nojvm -r \"gammafit('#{permdump}','#{meandump}','#{statdump}');exit\"")
    end
    sh("3dUndump -master #{mean_masked_full} -ijk -datum float -prefix #{parametric_pvals_prefix} #{statdump}")
    sh("3dcalc -prefix #{parametric_pvals_filled_prefix} -a #{parametric_pvals_full} -b #{thresh_full} -expr 'ifelse(not(a)*step(b),-(101-b)/100,a)'")
    if scale
      sh("3dcalc -prefix #{mean_scaled_prefix} -a #{mean_masked_full} -b #{pmax_full} -expr 'a-(b*notzero(a))'")
      sh("3dbucket -fbuc -prefix #{target_prefix} #{mean_scaled_full} #{thresh_full} #{parametric_pvals_filled_full}")
    else
      sh("3dbucket -fbuc -prefix #{target_prefix} #{mean_masked_full} #{thresh_full} #{parametric_pvals_filled_full}")
    end
    FileUtils.mv(statdump,'.')
    FileUtils.mv("#{dir}/statdump.params.txt",'.')
    FileUtils.mv(permdump,'.')
    FileUtils.mv(meandump,'.')
#    # Compute binomial p-value
#    sh("3drefit -fibn -statpar #{nperm} #{prob} #{target}")
#    # Add FDR curves
#    sh("3drefit -addFDR #{target}")
  end
end

def nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask, blur=0)
  # If a blur option is passed, then temporary blurred versions of the source
  # and permutation files are generated and the rank is computed wrt those
  # blurred datasets. These blurred datasets are deleted after use.
  target_prefix, target_ext = target.split('+')
  target_prefix_b  = File.basename(target_prefix)
  source_prefix, source_ext = source.split('+')
  source_prefix_b  = File.basename(source_prefix)
  Dir.mktmpdir do |dir|
    nzcount_prefix = File.join(dir,['nzcount',target_prefix_b].join('_'))
    nzcount_full = [nzcount_prefix,target_ext].join('+')
    gtcount_prefix = File.join(dir,['gtcount',target_prefix_b].join('_'))
    gtcount_full = [gtcount_prefix,target_ext].join('+')
    gtperm_list = []
    bperm_list = perm_list.collect {|x| File.join(dir,'b'+File.basename(x))}

    if blur > 0 then
      bsource_prefix = File.join(dir,['b',source_prefix_b].join('_'))
      bsource_full = [bsource_prefix,source_ext].join('+')
      sh("3dmerge -1blur_fwhm #{blur} -prefix #{bsource_prefix} #{source}")
    end

    perm_list.each do |permutation|
      perm_prefix_b, perm_ext = File.basename(permutation).split('+')
      # # THIS PROBABLY IS NOT A DIRECTION I WANT TO GO IN...
      # if (perm_ext.includes?('orig') and target_ext.includes?('tlrc')) then
      #   ctperm_prefix = File.join(dir,'ct'+perm_prefix_b)
      #   ctperm_full = [ctperm_prefix,perm_ext].join('+')
      #   if perm_prefix_b.last(2).eql?('_O') then
      #     ooperm_full = premutation
      #     coperm_prefix = File.join(dir,'co'+perm_prefix_b)
      #     coperm_full = [coperm_prefix,perm_ext].join('+')
      #     afni_deoblique(coperm_full, ooperm_full)
      #     afni_adwarp(source, reference, voxdim=3)
      #   end
      #   if perm_prefix_b.last(2).eql?('_C') then
      #     coperm_full = permutation
      #     afni_adwarp(source, reference, voxdim=3)
      #   end
      #   ctperm_prefix = File.join(dir,'ct'+perm_prefix_b)
      #   ctperm_full = [ctperm_prefix,perm_ext].join('+')
      # end
      gtperm_prefix = File.join(dir,'gt'+perm_prefix_b)
      gtperm_full = [gtperm_prefix,perm_ext].join('+')

      if blur > 0 then
        bperm_prefix  = File.join(dir,'b'+perm_prefix_b)
        bperm_full  = [bperm_prefix,perm_ext].join('+')
        sh("3dmerge -1blur_fwhm #{blur} -prefix #{bperm_prefix} #{permutation}")
        sh("3dcalc -a #{bsource_full} -b #{bperm_full} -expr 'step(a-b)' -prefix #{gtperm_prefix}")
      else
        sh("3dcalc -a #{source} -b #{permutation} -expr 'step(a-b)' -prefix #{gtperm_prefix}")
      end
      gtperm_list.push(gtperm_full)
    end
    if blur > 0 then
      sh("3dmerge -gcount -prefix #{nzcount_prefix} #{bperm_list.join(' ')}")
    else
      sh("3dmerge -gcount -prefix #{nzcount_prefix} #{perm_list.join(' ')}")
    end
    sh("3dmerge -gcount -prefix #{gtcount_prefix} #{gtperm_list.join(' ')}")

    # expression = "'ifelse(iszero(c),((step(b)*100)-b)/2,ifelse(ispositive(c),a,step(a+b)*50))'"
    # sh("3dcalc -a #{gtcount_full} -b #{nzcount_full} -c #{source} -prefix #{target_prefix} -expr #{expression}")
    #
    expression = "'ifelse(and(iszero(d),c),(100-b)/2,ifelse(and(ispositive(d),c),a,50))'"
    if blur > 0 then
      sh("3dcalc -a #{gtcount_full} -b #{nzcount_full} -c #{mask} -d #{bsource_full} -prefix #{target_prefix} -expr #{expression}")
    else
      sh("3dcalc -a #{gtcount_full} -b #{nzcount_full} -c #{mask} -d #{source} -prefix #{target_prefix} -expr #{expression}")
    end
  end
end

def nonparametric_count_median_thresholded_ranks(target,rank_list,intensitymap='', medianrank: 50, prob: 0.5)
  # This function takes the rank values for each subject, thresholds them at
  # the median rank (50), and then counts the number of subjects that survive
  # thresholding at each voxel. These counts are intended to be used as a
  # threshold. If you provide an intensity map, the count threshold will be
  # combined with it to create a new intensity+threshold dataset.
  target_prefix, target_ext = target.split('+')
  target_prefix_b  = File.basename(target_prefix)
  nsubj = rank_list.size
  Dir.mktmpdir do |dir|
    rankcount_prefix = File.join(dir,['rankcount',target_prefix_b].join('_'))
    rankcount_full = [rankcount_prefix,target_ext].join('+')
    sh("3dmerge -1clip #{medianrank + 0.01} -gcount -prefix #{rankcount_prefix} #{rank_list.join(' ')}")
    if (intensitymap) then
      sh("3dbucket -fbuc -prefix #{target_prefix} #{intensitymap} #{rankcount_full}")
      sh("3drefit -fith #{target}")
    else
      sh("3dbucket -fbuc -prefix #{target_prefix} #{rankcount_full}")
    end
    # Compute binomial p-value
    sh("3drefit -fibn -statpar #{nsubj} #{prob} #{target}")
    # Add FDR curves
    sh("3drefit -addFDR #{target}")
  end
end

def parametric_zscore(target, source, mean, sd)
  target_prefix = target.split('+').first
  sh("3dcalc -a #{source} -b #{mean} -c #{sd} -expr 'min((a-b)/c,5)*notzero(a)' -prefix #{target_prefix}")
end
