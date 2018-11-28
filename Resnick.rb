class Resnick
  attr_accessor :u_i_matrix, :users, :items

  def initialize
    @u_i_matrix = [[1, 4, 4, nil, 3, nil],
                   [1, 5, nil, 2, 4, 5],
                   [nil, 3, 5, nil, 5, nil],
                   [3, nil, 3, nil, 4, 1],
                   [1, 1, nil, 5, 4, 3]]

    @users = [1,2,3,4,5]
    @items = [1,2,3,4,5,6]
  end

  def common_ratings(a, i)
    common_rated = []
    j = 0
    @u_i_matrix[a].each do |rating|
      if !rij(i,j).nil? && !rating.nil?
        common_rated << j
      end
      j += 1
    end
    return common_rated
  end

  def mean_rating(a)
    ra = 0.00 #Mean ratings
    not_nils = @u_i_matrix[a].select {|position| !position.nil? }
    not_nils.each do |position|
        ra += position
    end

    ra /= not_nils.size

    ra = ra.round(2)

    return ra
  end

  def mean_ratings(a, i)
    ra = 0.00 #Mean ratings
    ri = 0.00

    j = 0
    count = 0

    common_rated = common_ratings(a, i)
    common_rated.each do |position|
      ra += rij(a,position)
      ri += rij(i,position)
    end

    ra /= common_rated.size
    ri /= common_rated.size

    ra = ra.round(2)
    ri = ri.round(2)

    return [ra, ri]
  end

  def rij(i, j)
    return @u_i_matrix[i][j]
  end

  def r_sub_mean(raj, ra)
    (raj - ra).round(2)
  end

  def summatory(a, i)
    common_rated = common_ratings(a, i)
    mean_ratings = mean_ratings(a,i)
    ra = mean_ratings[0]
    ri = mean_ratings[1]
    summatory = 0
    common_rated.each do |j|
      summatory += r_sub_mean(rij(a,j),ra)*r_sub_mean(rij(i,j),ri)
    end
    return summatory
  end

  def squared_multiplication_of_summatories(a, i)
    common_rated = common_ratings(a, i)
    mean_ratings = mean_ratings(a,i)
    ra = mean_ratings[0]
    ri = mean_ratings[1]
    summatoryra = 0
    summatoryri = 0
    common_rated.each do |j|
      summatoryra += (r_sub_mean(rij(a,j),ra))**2
      summatoryri += (r_sub_mean(rij(i,j),ri))**2
    end

    divider = Math.sqrt(summatoryra*summatoryri)
    return divider.round(2)
  end

  def pearson_correlation(a,i)
    a = a - 1
    i = i - 1
    w = summatory(a,i)/squared_multiplication_of_summatories(a,i)
    return w.round(2)
  end

  def neighbourhood(k, ws)
    wtemp = []
    wtemp << ws
    wtemp.flatten!
    neighbourhood = []
    i = 0
    while i != k
      neighbourhood << ws.index(wtemp.max)
      wtemp.delete_at(wtemp.index(wtemp.max))
      i+=1
    end
    return neighbourhood
  end

  def weighted_rating(w, i, j)
    return w*(rij(i, j)-mean_rating(i))
  end

  def resnick(a, ws, neighboorhood, j)
    a -= 1
    j -= 1
    summ = 0
    neighboorhood.each do |n|
      summ +=weighted_rating(ws[n], n, j)
    end
    summ /= summatory_of_weights(neighboorhood, ws)
    summ += mean_rating(a)
    return summ.round(2)
  end

  def summatory_of_weights(neighboorhood, ws)
    summ = 0.00
    neighboorhood.each do |n|
      summ += ws[n].abs
    end
    return summ
  end

  def MSD(a,i)
    summ = 0.00
    common_rated = common_ratings(a,i)
    common_rated.each {|j| summ += (rij(a,j) - rij(i,j))**2}
    summ /= common_rated.size
    return summ.round(2)
  end

  def rmax(a,i)
    a = @u_i_matrix[a].select {|position| !position.nil? }
    i = @u_i_matrix[i].select {|position| !position.nil? }
    ramax = a.max
    rimax = i.max
    ramax > rimax ?
        ramax:rimax
  end

  def rmin(a,i)
    a = @u_i_matrix[a].select {|position| !position.nil? }
    i = @u_i_matrix[i].select {|position| !position.nil? }
    ramin = a.min
    rimin = i.min
    ramin > rimin ?
        rimin:ramin
  end

  def MSD_weitgh(a,i)
    a = a - 1
    i = i - 1
    msdai = MSD(a,i)
    rmax = rmax(a,i)
    rmin = rmin(a,i)
    summ = (1 - (msdai/(rmax - rmin)**2)).round(2)
    return summ
  end

  def to_s
    str = "INPUT MATRIX:\n\n\t"
    @items.each{|x| str += "item: #{x}\t"}
    matrix = "\n"
    @u_i_matrix.map.with_index {|x,i| matrix << "user: #{i+1} |\t"+x.join("\t")+"\n"}
    str += matrix
  end
end

lab8 = Resnick.new
puts(lab8.to_s)
a = 5
others = lab8.users.select {|users| users != a}
ws = []
others.each do |i|
  ws << lab8.pearson_correlation(a,i)
end
k = 2
puts("\nPEARON CORRELATION\nWEIGHTS: #{ws}")
neighbourhood = lab8.neighbourhood(2, ws)
neighbourhood_to_print = neighbourhood.collect {|i| i + 1}
puts("NEIGHBOURHOOD: #{neighbourhood_to_print}")
resnick = lab8.resnick(a, ws, neighbourhood, 3)
puts("RESNICK: #{resnick}")
ws = []
others.each do |i|
  ws << lab8.MSD_weitgh(a, i)
end
puts("\nMEAN SQUARED DIFFERENCE\nWEIGHTS: #{ws}")
neighbourhood = lab8.neighbourhood(2, ws)
neighbourhood_to_print = neighbourhood.collect {|i| i + 1}
puts("NEIGHBOURHOOD: #{neighbourhood_to_print}")
resnick = lab8.resnick(a, ws, neighbourhood, 3)
puts("RESNICK: #{resnick}")