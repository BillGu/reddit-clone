module CommentsHelper
  def comments_hash(comments)
    hash = Hash.new { |h, k| h[k] = [] }

    comments.each { |c| hash[c.parent_comment_id] << c }
    hash
  end

  # def formatted_comments(comments, start_key, type = 'classic', hide = true)
  #   return nil if comments.empty?
  #   hash = comments_hash(comments)

  #   return threaded_comments(hash, start_key).html_safe if type == 'classic'
  #   flat_comments(hash, start_key, 'blue', hash[start_key].first, hide).html_safe
  # end

  def formatted_comments(comments, start_key, type = 'classic', hide = true)
    return nil if comments.empty?
    hash = comments_hash(comments)

    return threaded_comments(hash, start_key).html_safe if type == 'classic'
    flat_comments(hash, start_key, hash[start_key].first, hide).html_safe
  end

  def flat_comments(hash, comment_id, parent = nil, hide = true, level = 'talk1')
    str = ''
    return str unless hash.key?(comment_id)

    level = ['talk1', 'talk_break'].include?(level) ? 'talk2' : 'talk1'

    hash[comment_id].each_with_index do |comment, idx|
      display = 'hide'
      if comment_id.nil?
        display = nil
        level = 'talk1'
        str += "#{'</div>' unless idx.zero?}<div class=\"parent\">#{replies_btn if hash.key?(comment.id)}"
      end
      str += "<div class=\"indent flat #{level} container #{display if hide}\">#{render("comments/single_comment", comment: comment, quote: parent_link(parent, level))}</div>"
      str += flat_comments(hash, comment.id, comment, hide, level)
      level = 'talk_break'
    end
    str
  end

  # def flat_comments(hash, comment_id, color = 'blue', parent = nil, hide = true)
  #   str = ''
  #   return str unless hash.key?(comment_id)

  #   color = ['blue', 'red'].include?(color) ? 'grey' : 'blue'

  #   hash[comment_id].each_with_index do |comment, idx|
  #     display = 'hide'
  #     if comment_id.nil?
  #       display = nil
  #       color = 'blue'
  #       str += "#{'</div>' unless idx.zero?}<div class=\"parent\">#{replies_btn if hash.key?(comment.id)}"
  #     end
  #     str += "<div class=\"indent flat #{color} container #{display if hide}\">#{render("comments/single_comment", comment: comment, quote: parent_link(parent, color))}</div>"
  #     str += flat_comments(hash, comment.id, color, comment, hide)
  #     color = 'red'
  #   end
  #   str
  # end

  def replies_btn
    '<button class="show-replies">Replies</button>'
  end

  def parent_link(parent, level)
    return nil if parent.nil? || level != 'talk_break'
    link = link_to('More', comment_url(parent), target: "_blank")
    "\"#{parent.quote}\" - #{link}"
  end

  # def parent_link(parent, color)
  #   return nil if parent.nil? || color != 'red'
  #   link = link_to('More', comment_url(parent), target: "_blank")
  #   "<div class=\"quote\">\"#{parent.quote}\" - #{link}</div>"
  # end

  def threaded_comments(hash, comment_id)
    str = ''
    return str unless hash.key?(comment_id)

    hash[comment_id].each do |comment|
      str += "<div class=\"indent\">" + render("comments/single_comment", comment: comment)
      str += threaded_comments(hash, comment.id) + '</div>'
    end
    str
  end
end
