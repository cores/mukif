
class Wish < ActiveRecord::Base

  # finders concern

  def self.paginate_user_wishes(user, params, args)
    paginate_by_user_id user,
                        :order => order_by(params[:order_by], params[:desc]),
                        :page => params[:page],
                        :per_page => args[:per_page]
  end

  def paginate_comments(params, args)
    WishComment.paginate_by_wish_id self,
                                    :order => 'created_at',
                                    :page => params[:page],
                                    :per_page => args[:per_page]
  end

  def paginate_bounties(params, args)
    WishBounty.paginate_by_wish_id self,
                                   :order => 'created_at',
                                   :page => params[:page],
                                   :per_page => args[:per_page]
  end

  def self.search(params, args)
    paginate :conditions => search_conditions(params),
             :order => order_by(params[:order_by], params[:desc]),
             :page => params[:page],
             :per_page => args[:per_page]
  end

  private
  
    def self.order_by(order_by, desc)
      "#{order_by}#{' DESC' if desc == '1'}"
    end

    def self.search_conditions(params)
      s, h = '', {}
      unless params[:keywords].blank?
        s << 'id IN (SELECT wish_id FROM wish_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE)) '
        h[:keywords] = params[:keywords]
        previous = true
      end
      unless params[:unfilled].blank?
        s << 'AND ' if previous
        s << 'filled = :filled '
        h[:filled] = params[:unfilled] != '1'
        previous = true
      end
      unless params[:type_id].blank?
        s << 'AND ' if previous
        s << 'type_id = :type_id '
        h[:type_id] = params[:type_id].to_i
        previous = true
      end
      unless params[:format_id].blank?
        s << 'AND ' if previous
        s << 'format_id = :format_id '
        h[:format_id] = params[:format_id].to_i
        previous = true
      end
      unless params[:country_id].blank?
        s << 'AND ' if previous
        s << 'country_id = :country_id '
        h[:country_id] = params[:country_id].to_i
        previous = true
      end
      [s, h]
    end
end
